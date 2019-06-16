import Foundation
import Combine

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
  func dispatch<Success, Decoder>(_ request: Request<Success, Decoder>) -> AnyPublisher<Success, Decoder.ErrorType>
    where Success: Decodable, Decoder: ResponseDecoder {
      typealias RequestFuture = Publishers.Future<Success, Decoder.ErrorType>
      return Publishers.Deferred<RequestFuture> {
        return RequestFuture { (fulfill) in
          var transportRequest = self.prepareUrlRequest(request)

          self.plugins.forEach {
            $0.preprocessUrlRequest(&transportRequest)
          }

          self.sendTransportRequest(transportRequest,
                                    requestType: type(of: request),
                                    completionQueue: .global()) { [weak self] result in
                                      self?.plugins.forEach {
                                        $0.didSendRequest(transportRequest, result: result)
                                      }
                                      fulfill(result)
          }
        }
      }.eraseToAnyPublisher()
  }
}
