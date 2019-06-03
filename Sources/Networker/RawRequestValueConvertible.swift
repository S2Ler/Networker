import Foundation

public protocol RawRequestValueConvertible {
  var rawRequestValue: String { get }
}

extension String: RawRequestValueConvertible {
  public var rawRequestValue: String { return self }
}

extension TimeInterval: RawRequestValueConvertible {
  public var rawRequestValue: String { return description }
}

extension Bool: RawRequestValueConvertible {
  public var rawRequestValue: String {
    return description
  }
}
