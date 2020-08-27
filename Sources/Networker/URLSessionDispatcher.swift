import Foundation
import Logging

public class URLSessionDispatcher: NSObject {
  private struct URLSessionInitData {
    let urlSessionConfiguration: URLSessionConfiguration
    let delegateQueue: OperationQueue?
  }

  private let jsonBodyEncoder: JSONEncoder
  private var urlSessionInitData: URLSessionInitData?
  private lazy var urlSession: URLSession = {
    guard let urlSessionInitData = self.urlSessionInitData else {
      preconditionFailure()
    }

    let urlSession = URLSession(configuration: urlSessionInitData.urlSessionConfiguration,
                                delegate: self,
                                delegateQueue: urlSessionInitData.delegateQueue)
    self.urlSessionInitData = nil
    return urlSession
  }()

  public let logger: Logger?
  @RWAtomic public var plugins: [DispatcherPlugin]

  public init(jsonBodyEncoder: JSONEncoder,
              plugins: [DispatcherPlugin],
              urlSessionConfiguration: URLSessionConfiguration = .default,
              urlSessionDelegateQueue: OperationQueue? = nil,
              logger: Logger? = nil) {
    self.jsonBodyEncoder = jsonBodyEncoder
    urlSessionInitData = URLSessionInitData(urlSessionConfiguration: urlSessionConfiguration,
                                            delegateQueue: urlSessionDelegateQueue)
    self.plugins = plugins
    self.logger = logger
  }
}

extension URLSessionDispatcher: Dispatcher {
  public func add(_ plugin: DispatcherPlugin) {
    _plugins.mutate { $0.append(plugin) }
  }

  public func prepareUrlRequest<Success, Decoder>(_ request: Request<Success, Decoder>) throws -> URLRequest {
    var urlRequest = URLRequest(url: request.url,
                                cachePolicy: request.cachePolicy,
                                timeoutInterval: request.timeout)
    func httpBody() throws -> Data? {
      switch request.body {
      case .raw(let data):
        return data
      case .string(let string):
        return Data(string.utf8)
      case .json(let encodable):
        return try encodable.encode(with: jsonBodyEncoder)
      case .custom(let bodyConvertible):
        return bodyConvertible.convertToRequestBody()
      case .none:
        return nil
      }
    }

    if let body = try httpBody() {
      urlRequest.httpBody = body
      urlRequest.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
    }
    urlRequest.httpMethod = request.httpMethod.rawValue
    if let headers = request.headers {
      for (key, value) in headers {
        urlRequest.setValue(value.rawRequestValue, forHTTPHeaderField: key)
      }
    }
    logger?.debug("Prepared URLRequest: \(urlRequest)")
    return urlRequest
  }

  public func sendTransportRequest<Success, Decoder>(
    _ urlRequest: URLRequest,
    requestType: Request<Success, Decoder>.Type,
    completionQueue: DispatchQueue,
    completion: @escaping (Result<Success, Swift.Error>) -> Void
  ) {
    let urlSessionTask = urlSession.dataTask(with: urlRequest) { [logger] data, response, error in
      // Log Response
      if let logger = logger, logger.logLevel == .debug {
        if let response = response {
          logger.debug("Response: \(response)")
        }
        if let error = error {
          logger.debug("-- Error: \(error)")
        }
        if let data = data {
          if data.count < 10000 {
            logger.debug("-- Raw Response:\n\(String(data: data, encoding: .utf8) ?? "Not UTF8 Response")")
          } else {
            logger.debug("-- Partial Raw Response:\n\(String(data: data[0..<10000], encoding: .utf8) ?? "Not UTF8 Response")")
          }
        }
      }

      let result = requestType.convert(data: data, response: response, error: error)
      completionQueue.async {
        completion(result.mapError{$0})
      }
    }

    urlSessionTask.resume()
  }
}

extension URLSessionDispatcher: URLSessionTaskDelegate {
  public func urlSession(_: URLSession,
                         task _: URLSessionTask,
                         didReceive challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    var challengeHandled: Bool = false

    for plugin in plugins {
      challengeHandled = plugin.fullFill(challenge: challenge,
                                         completion: completionHandler)
      if challengeHandled {
        break
      }
    }

    if !challengeHandled {
      completionHandler(.performDefaultHandling, nil)
    }
  }
}
