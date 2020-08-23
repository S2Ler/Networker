import Foundation
import Logging

public protocol Dispatcher: AnyObject {
  var logger: Logger? { get }
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
