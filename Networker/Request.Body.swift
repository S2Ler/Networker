import Foundation

public extension Request {
  enum Body {
    case raw(Data)
    case string(String)
    case json(Encodable)
    case custom(RequestBodyConvertible)
  }
}

public protocol RequestBodyConvertible {
  func convertToRequestBody() -> Data
}
