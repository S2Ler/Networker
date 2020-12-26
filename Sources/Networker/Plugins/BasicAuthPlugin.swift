import Foundation

public final class BasicAuthPlugin: DispatcherPlugin {
  private let username: String
  private let password: String
  
  public init(username: String,
              password: String) {
    self.username = username
    self.password = password
  }
  
  public func fullFill(challenge: URLAuthenticationChallenge,
                       completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Bool {
    guard challenge.previousFailureCount == 0 else {
      completion(.cancelAuthenticationChallenge, nil)
      return true
    }
    
    let credential: URLCredential
    
    switch challenge.protectionSpace.authenticationMethod {
    case NSURLAuthenticationMethodServerTrust:
      credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
    default:
      credential = URLCredential(user: username,
                                 password: password,
                                 persistence: URLCredential.Persistence.none)
    }
    
    completion(.useCredential, credential)
    
    return true
  }
}
