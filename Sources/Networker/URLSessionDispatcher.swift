import Foundation

public class URLSessionDispatcher: NSObject {
  private struct URLSessionInitData {
    let urlSessionConfiguration: URLSessionConfiguration
    let delegateQueue: OperationQueue?
  }

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

  private var rwAtomicPlugins: RWAtomic<[DispatcherPlugin]>

  public init(plugins: [DispatcherPlugin],
              urlSessionConfiguration: URLSessionConfiguration = .default,
              urlSessionDelegateQueue: OperationQueue? = nil) {
    urlSessionInitData = URLSessionInitData(urlSessionConfiguration: urlSessionConfiguration,
                                            delegateQueue: urlSessionDelegateQueue)
    rwAtomicPlugins = RWAtomic(plugins)
  }
}

extension URLSessionDispatcher: Dispatcher {
  public var plugins: [DispatcherPlugin] {
    get {
      return rwAtomicPlugins.value
    }
    set {
      rwAtomicPlugins.mutate { value in
        value = newValue
      }
    }
  }

  public func add(_ plugin: DispatcherPlugin) {
    rwAtomicPlugins.mutate { value in
      value.append(plugin)
    }
  }

  public func prepareUrlRequest<Success, Decoder>(_ request: Request<Success, Decoder>) -> URLRequest {
    let urlRequest = URLRequest(url: request.url,
                                cachePolicy: request.cachePolicy,
                                timeoutInterval: request.timeout)
    return urlRequest
  }

  public func sendTransportRequest<Success, Decoder>(_ urlRequest: URLRequest,
                                                     requestType: Request<Success, Decoder>.Type,
                                                     completionQueue: DispatchQueue,
                                                     completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void) {
    let urlSessionTask = urlSession.dataTask(with: urlRequest) { data, response, error in
      let result = requestType.convert(data: data, response: response, error: error)
      completionQueue.async {
        completion(result)
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
