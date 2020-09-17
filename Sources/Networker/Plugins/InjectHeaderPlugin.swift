import Foundation

public final class InjectHeaderPlugin: DispatcherPlugin {
  private let headerField: String
  private let dynamicValue: () -> String

  public init(headerField: String, dynamicValue: @escaping () -> String) {
    self.headerField = headerField
    self.dynamicValue = dynamicValue
  }

  public convenience init(headerField: String, value: String) {
    self.init(headerField: headerField, dynamicValue: { value })
  }

  public func preprocessUrlRequest(_ urlRequest: inout URLRequest) {
    urlRequest.addValue(dynamicValue(), forHTTPHeaderField: headerField)
  }
}
