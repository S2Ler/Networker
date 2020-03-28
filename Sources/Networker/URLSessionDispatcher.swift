import Foundation

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

    let operationQueue = OperationQueue()
    let urlSession = URLSession(configuration: urlSessionInitData.urlSessionConfiguration,
                                delegate: self,
                                delegateQueue: urlSessionInitData.delegateQueue)
    self.urlSessionInitData = nil
    return urlSession
  }()

  @RWAtomic public var plugins: [DispatcherPlugin]

  public init(jsonBodyEncoder: JSONEncoder,
              plugins: [DispatcherPlugin],
              urlSessionConfiguration: URLSessionConfiguration = .default,
              urlSessionDelegateQueue: OperationQueue? = nil) {
    self.jsonBodyEncoder = jsonBodyEncoder
    urlSessionInitData = URLSessionInitData(urlSessionConfiguration: urlSessionConfiguration,
                                            delegateQueue: urlSessionDelegateQueue)
    self.plugins = plugins
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
    return urlRequest
  }

  public func sendTransportRequest<Success, Decoder>(
    _ urlRequest: URLRequest,
    requestType: Request<Success, Decoder>.Type,
    completionQueue: DispatchQueue,
    completion: @escaping (Result<Success, Swift.Error>) -> Void
  ) {
    let urlSessionTask = urlSession.dataTask(with: urlRequest) { data, response, error in
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
