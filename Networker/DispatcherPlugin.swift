import Foundation

public protocol DispatcherPlugin {
  func preprocessUrlRequest(_ urlRequest: inout URLRequest)

  func didSendRequest<Success, ErrorType>(_ urlRequest: URLRequest, result: Result<Success, ErrorType>)
    where Success: Decodable,
    ErrorType: Swift.Error
}

extension DispatcherPlugin {
  public func preprocessRequest(_: inout URLRequest) {}
  public func didSendRequest<Success, ErrorType>(_: URLRequest, result _: Result<Success, ErrorType>)
    where Success: Decodable,
    ErrorType: Swift.Error {}
}

public final class InjectHeaderPlugin: DispatcherPlugin {
  private let headerField: String
  private let value: String

  public init(headerField: String, value: String) {
    self.headerField = headerField
    self.value = value
  }

  public func preprocessUrlRequest(_ urlRequest: inout URLRequest) {
    urlRequest.addValue(value, forHTTPHeaderField: headerField)
  }
}
