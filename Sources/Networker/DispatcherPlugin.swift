import Foundation

public protocol DispatcherPlugin {
  func preprocessUrlRequest(_ urlRequest: inout URLRequest)

  /// Return true if challenge will be fullfilled
  func fullFill(challenge: URLAuthenticationChallenge,
                completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Bool

  func didSendRequest<Success, ErrorType>(_ urlRequest: URLRequest, result: Result<Success, ErrorType>)
    where Success: Decodable,
    ErrorType: Swift.Error
}

extension DispatcherPlugin {
  public func preprocessUrlRequest(_: inout URLRequest) {}

  public func fullFill(challenge _: URLAuthenticationChallenge,
                       completion _: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Bool {
    return false
  }

  public func didSendRequest<Success, ErrorType>(_: URLRequest, result _: Result<Success, ErrorType>)
    where Success: Decodable,
    ErrorType: Swift.Error {}
}
