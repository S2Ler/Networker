import Foundation

public struct RequestPath {
  public var pattern: String
  public var parameters: [String: RawRequestValueConvertible]?

  /// - parameter pattern: `/api/bot/{id}` where `id` is parameter in `parameters`
  /// - parameter parameters: replaces "{PARAMETER_NAME}" inside `patter` with PARAMETER_VALUE where:
  /// `PARAMETER_NAME` = key in `parameters` and `PARAMETER_VALUE` = value in `parameters`
  public init(pattern: String, parameters: [String: RawRequestValueConvertible]? = nil) {
    self.pattern = pattern
    self.parameters = parameters
  }

  internal var raw: String {
    if let parameters = parameters {
      var raw: String = ""
      var id: String = ""
      var opened: Bool = false
      for c in pattern {
        if c == "}" {
          if !id.isEmpty {
            if let value = parameters[id] {
              raw.append(value.rawRequestValue)
            } else {
              raw.append("{\(id)}")
            }
          } else {
            raw.append("{}")
          }
          opened = false
          id = ""
        } else if c == "{" {
          opened = true
          id = ""
        } else {
          if opened {
            id.append(c)
          } else {
            raw.append(c)
          }
        }
      }
      return raw
    } else {
      return pattern
    }
  }
}

extension RequestPath: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    pattern = value
    parameters = nil
  }
}
