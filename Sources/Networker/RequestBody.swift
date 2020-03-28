import Foundation

public enum RequestBody {
  case raw(Data)
  case string(String)
  case json(Encodable)
  case custom(RequestBodyConvertible)
}

public protocol RequestBodyConvertible {
  func convertToRequestBody() -> Data
}

internal extension Encodable {
  func encode(with encoder: JSONEncoder) throws -> Data {
    try encoder.encode(self)
  }
}
