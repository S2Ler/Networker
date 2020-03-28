import Foundation
import Combine

public protocol Dispatcher: AnyObject {
  var plugins: [DispatcherPlugin] { get set }
  func add(_ plugin: DispatcherPlugin)

  func prepareUrlRequest<Success, Decoder>(
    _ request: Request<Success, Decoder>
  ) throws -> URLRequest
  
  func sendTransportRequest<Success, Decoder>(
    _ urlRequest: URLRequest,
    requestType: Request<Success, Decoder>.Type,
    completionQueue: DispatchQueue,
    completion: @escaping (Result<Success, Swift.Error>) -> Void
  )
}

public extension Dispatcher {
  func dispatch<Success, Decoder>(
    _ request: Request<Success, Decoder>
  ) -> AnyPublisher<Success, Swift.Error>
    where Success: Decodable, Decoder: ResponseDecoder
  {
    typealias RequestFuture = Future<Success, Swift.Error>
    return Deferred<RequestFuture> {
      return RequestFuture { (fulfill) in
        do {
          var transportRequest = try self.prepareUrlRequest(request)

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
        catch let error {
          fulfill(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}
