import Foundation

public protocol Dispatcher: AnyObject {
  var plugins: [DispatcherPlugin] { get set }
  func add(_ plugin: DispatcherPlugin)

  func prepareUrlRequest<Success, Decoder>(_ request: Request<Success, Decoder>) -> URLRequest
  func sendTransportRequest<Success, Decoder>(_ urlRequest: URLRequest,
                                              requestType: Request<Success, Decoder>.Type,
                                              completionQueue: DispatchQueue,
                                              completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void)
}

public extension Dispatcher {
  func dispatch<Success, Decoder>(_ request: Request<Success, Decoder>,
                                  completionQueue: DispatchQueue,
                                  completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void)
    where Success: Decodable, Decoder: ResponseDecoder {
    var transportRequest = prepareUrlRequest(request)

    plugins.forEach {
      $0.preprocessUrlRequest(&transportRequest)
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
