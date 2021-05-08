import Foundation

public extension Dispatcher {
  func dispatch<Success, Decoder>(_ request: Request<Success, Decoder>) async throws -> Success
  where
    Success: Decodable,
    Decoder: ResponseDecoder
  {
    logger?.debug("Dispatching request: \(request)")

    var transportRequest = try self.prepareUrlRequest(request)

    self.plugins.forEach {
      $0.preprocessUrlRequest(&transportRequest)
    }

    do {
      let resultValue = try await self.sendTransportRequest(transportRequest, requestType: type(of: request))
      plugins.forEach {
        $0.didSendRequest(transportRequest, result: .success(resultValue))
      }
      return resultValue
    }
    catch {
      plugins.forEach {
        $0.didSendRequest(transportRequest, result: Result<Success, Swift.Error>.failure(error))
      }
      throw error
    }
  }
}
