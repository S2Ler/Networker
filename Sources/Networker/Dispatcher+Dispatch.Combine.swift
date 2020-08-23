#if canImport(Combine)
import Foundation
import Combine

@available(OSX 10.15, *)
public extension Dispatcher {
  func dispatch<Success, Decoder>(
    _ request: Request<Success, Decoder>
  ) -> AnyPublisher<Success, Swift.Error>
    where Success: Decodable, Decoder: ResponseDecoder
  {
    typealias RequestFuture = Future<Success, Swift.Error>
    return Deferred<RequestFuture> {
      RequestFuture { (fulfill) in
        self.dispatch(request, completionQueue: .global()) { (result) in
          fulfill(result)
        }
      }
    }.eraseToAnyPublisher()
  }
}
#endif
