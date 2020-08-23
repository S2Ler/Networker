import Foundation

public extension Dispatcher {
  func dispatch<Success, Decoder>(
    _ request: Request<Success, Decoder>,
    completionQueue: DispatchQueue,
    completion: @escaping (Result<Success, Swift.Error>) -> Void
  )
    where Success: Decodable, Decoder: ResponseDecoder
  {
    do {
      logger?.debug("Dispatching request: \(request)")

      var transportRequest = try self.prepareUrlRequest(request)

      self.plugins.forEach {
        $0.preprocessUrlRequest(&transportRequest)
      }

      self.sendTransportRequest(transportRequest,
                                requestType: type(of: request),
                                completionQueue: completionQueue) { [weak self] result in
        self?.plugins.forEach {
          $0.didSendRequest(transportRequest, result: result)
        }
        completion(result)
      }
    }
    catch let error {
      completionQueue.async {
        completion(.failure(error))
      }
    }
  }
}
