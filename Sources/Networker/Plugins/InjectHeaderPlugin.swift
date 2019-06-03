import Foundation

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
