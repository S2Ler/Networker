import Foundation

public protocol Dispatcher: AnyObject {
  var plugins: [DispatcherPlugin] { get }
  func prepareUrlRequest<Success, Decoder>(_ request: Request<Success, Decoder>) throws -> URLRequest
  func sendTransportRequest<Success, Decoder>(_ urlRequest: URLRequest,
                                              requestType: Request<Success, Decoder>.Type,
                                              completionQueue: DispatchQueue,
                                              completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void)
}

public extension Dispatcher {
  func dispatch<Success, Decoder>(_ request: Request<Success, Decoder>,
                                  completionQueue: DispatchQueue,
                                  completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void) throws
    where Success: Decodable, Decoder: ResponseDecoder {
    var transportRequest = try prepareUrlRequest(request)

    plugins.forEach {
      $0.preprocessRequest(&transportRequest)
    }

    sendTransportRequest(transportRequest,
                         requestType: type(of: request),
                         completionQueue: .global()) { [weak self] result in
      self?.plugins.forEach {
        $0.didSendRequest(transportRequest, result: result)
      }
      completionQueue.async {
        completion(result)
      }
    }
  }
}

public class URLSessionDispatcher: Dispatcher {
  public private(set) var plugins: [DispatcherPlugin] = []

  public func prepareUrlRequest<Success, Decoder>(_ request: Request<Success, Decoder>) throws -> URLRequest {
    let urlRequest = URLRequest(url: try request.url().get(),
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
