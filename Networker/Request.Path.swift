import Foundation

public struct RequestPath {
  public enum Error: Swift.Error {
    case patternWithoutLeadingSlash
  }

  private enum Constants {
    static let sampleBaseUrlComponents: URLComponents = URLComponents(string: "https://server.local/api")!
  }

  public typealias Parameters = [String: RawRequestValueConvertible]
  private let pattern: String
  private let parameters: Parameters?

  /// If correct url cannot be constructed from provided inputs it will crash.
  /// - parameter pattern: `/api/bot/{id}` where `id` is parameter in `parameters`
  /// - parameter parameters: replaces "{PARAMETER_NAME}" inside `patter` with PARAMETER_VALUE where:
  /// `PARAMETER_NAME` = key in `parameters` and `PARAMETER_VALUE` = value in `parameters`
  public init(pattern: StaticString, parameters: Parameters? = nil) {
    let pattern = pattern.description

    do {
      try RequestPath.validateInputs(pattern: pattern, parameters: parameters)
    } catch {
      preconditionFailure("Invalid path. Error: \(error)")
    }

    self.pattern = pattern
    self.parameters = parameters
  }

  /// Same as the variant with StaticString pattern buy throws instead of crashing.
  public init(dynamicPattern: String, parameters: Parameters? = nil) throws {
    try RequestPath.validateInputs(pattern: dynamicPattern, parameters: parameters)

    pattern = dynamicPattern
    self.parameters = parameters
  }

  private static func validateInputs(pattern: String, parameters: Parameters?) throws {
    assert(!Constants.sampleBaseUrlComponents.path.hasSuffix("/"))

    guard pattern.hasPrefix("/") else {
      throw Error.patternWithoutLeadingSlash
    }

    let rawPath = self.rawPath(pattern: pattern, parameters: parameters)
    var urlComponents = Constants.sampleBaseUrlComponents
    urlComponents.path.append(rawPath)

    guard urlComponents.url != nil else {
      preconditionFailure("Something wrong with constucting url from \(urlComponents)")
    }
  }

  internal func combine(withBaseUrl baseUrl: URL) -> URLComponents {
    guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
      preconditionFailure("Can't construct URLComponents from baseUrl")
    }

    if components.path.hasPrefix("/") {
      components.path.removeFirst()
    }

    components.path.append(raw)

    return components
  }

  internal var raw: String {
    return RequestPath.rawPath(pattern: pattern, parameters: parameters)
  }

  private static func rawPath(pattern: String, parameters: Parameters?) -> String {
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
