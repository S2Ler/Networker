import Foundation
import Logging

public final class URLSessionDispatcher {
  private final class Delegate: NSObject, URLSessionTaskDelegate {
    @RWAtomic var plugins: [DispatcherPlugin] = .init([])

    func urlSession(_: URLSession,
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

    public func add(_ plugin: DispatcherPlugin) {
      _plugins.mutate { $0.append(plugin) }
    }
  }
  
  private let jsonBodyEncoder: JSONEncoder
  private let urlSession: URLSession
  private let urlSessionDelegate: Delegate
  
  public let logger: Logger?

  public init(jsonBodyEncoder: JSONEncoder,
              plugins: [DispatcherPlugin],
              urlSessionConfiguration: URLSessionConfiguration = .default,
              urlSessionDelegateQueue: OperationQueue? = nil,
              logger: Logger? = nil) {
    self.jsonBodyEncoder = jsonBodyEncoder
    self.logger = logger

    let delegate = Delegate()
    self.urlSessionDelegate = delegate
    self.urlSession = URLSession(configuration: urlSessionConfiguration,
                                 delegate: delegate,
                                 delegateQueue: urlSessionDelegateQueue)
  }
}

extension URLSessionDispatcher: Dispatcher {
  public var plugins: [DispatcherPlugin] {
    get {
      urlSessionDelegate.plugins
    }
    set {
      urlSessionDelegate.plugins = newValue
    }
  }

  public func add(_ plugin: DispatcherPlugin) {
    urlSessionDelegate.add(plugin)
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
    requestType: Request<Success, Decoder>.Type
  ) async throws -> Success {
    let result: Result<Success, Error>
    do {
      let (data, response) = try await urlSession.data(for: urlRequest)

      // Log Response
      if let logger = logger, logger.logLevel == .debug {
        logger.debug("Response: \(response)")
        if data.count < 10000 {
          logger.debug("-- Raw Response:\n\(String(data: data, encoding: .utf8) ?? "Not UTF8 Response")")
        } else {
          logger.debug("-- Partial Raw Response:\n\(String(data: data[0..<10000], encoding: .utf8) ?? "Not UTF8 Response")")
        }
      }

       result = requestType.convert(.success((data, response)))
    }
    catch {
      logger?.debug("-- Error: \(error)")
      result = requestType.convert(.failure(error))
    }

    switch result {
    case .success(let value):
      return value
    case .failure(let failure):
      throw failure
    }
  }
}
