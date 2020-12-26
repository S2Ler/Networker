import Foundation

public protocol DispatcherPlugin {
  func preprocessUrlRequest(_ urlRequest: inout URLRequest)
  
  /// Return true if challenge will be fulfilled
  func fullFill(challenge: URLAuthenticationChallenge,
                completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Bool
  
  func didSendRequest<Success>(_ urlRequest: URLRequest, result: Result<Success, Swift.Error>) where Success: Decodable
}

extension DispatcherPlugin {
  public func preprocessUrlRequest(_: inout URLRequest) {}
  
  public func fullFill(challenge _: URLAuthenticationChallenge,
                       completion _: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Bool {
    return false
  }
  
  public func didSendRequest<Success>(_: URLRequest, result _: Result<Success, Swift.Error>) where Success: Decodable
  {
    // no-op
  }
}
