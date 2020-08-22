import Foundation
import Networker
import Combine
import Logging

internal final class MockDispatcher: Dispatcher {
  private let urlSessionDispatcher: URLSessionDispatcher
  private let finalRequestHandler: (URLRequest) -> Void

  @RWAtomic var plugins: [DispatcherPlugin]
  var logger: Logger? { nil }

  internal init(finalRequestHandler: @escaping (URLRequest) -> Void) {
    self.finalRequestHandler = finalRequestHandler
    urlSessionDispatcher = URLSessionDispatcher(jsonBodyEncoder: JSONEncoder(), plugins: [])
    plugins = []
  }

  func prepareUrlRequest<Success, Decoder>(_ request: Request<Success, Decoder>) throws -> URLRequest {
    return try urlSessionDispatcher.prepareUrlRequest(request)
  }

  func sendTransportRequest<Success, Decoder>(
    _ urlRequest: URLRequest,
    requestType: Request<Success, Decoder>.Type,
    completionQueue: DispatchQueue,
    completion: @escaping (Result<Success, Error>) -> Void
  ) where Success : Decodable, Decoder : ResponseDecoder {
    finalRequestHandler(urlRequest)
    completionQueue.async { completion(requestType.convert(data: nil, response: nil, error: nil).mapError{$0}) }
  }

  func add(_ plugin: DispatcherPlugin) {
    plugins.append(plugin)
  }
}
