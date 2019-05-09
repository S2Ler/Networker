import Foundation

public class URLSessionDispatcher {
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

  private var rwAtomicPlugins: RWAtomic<[DispatcherPlugin]>

  public init(plugins: [DispatcherPlugin]) {
    rwAtomicPlugins = RWAtomic(plugins)
  }
}

extension URLSessionDispatcher: Dispatcher {
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
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      let result = requestType.convert(data: data, response: response, error: error)
      completionQueue.async {
        completion(result)
      }
    }
  }
}
