import Foundation
import Networker
import Combine

internal final class MockDispatcher: Dispatcher {
  private let urlSessionDispatcher: URLSessionDispatcher
  private let finalRequestHandler: (URLRequest) -> Void
  @RWAtomic var plugins: [DispatcherPlugin]

  internal init(finalRequestHandler: @escaping (URLRequest) -> Void) {
    self.finalRequestHandler = finalRequestHandler
    urlSessionDispatcher = URLSessionDispatcher(plugins: [])
    plugins = []
  }

  func prepareUrlRequest<Success, Decoder>(_ request: Request<Success, Decoder>) -> URLRequest {
    return urlSessionDispatcher.prepareUrlRequest(request)
  }

  func sendTransportRequest<Success, Decoder>(_ request: URLRequest,
                                              requestType: Request<Success, Decoder>.Type,
                                              completionQueue: DispatchQueue,
                                              completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void) {
    finalRequestHandler(request)
    completionQueue.async { completion(requestType.convert(data: nil, response: nil, error: nil)) }
  }

  func add(_ plugin: DispatcherPlugin) {
    plugins.append(plugin)
  }
}
