@testable import Networker
import XCTest

class PathTests: XCTestCase {
  func testRawPath() {
    test("/api/bots", expected: "/api/bots")
  }

  func testExpressibleByStringLiteral() {
    let path: Request.Path = "/api/integrations"
    XCTAssertEqual(path.raw, "/api/integrations")
  }

  func testExpressibleByStringLiteralIgnoresParameters() {
    let path: Request.Path = "/api/integrations/{id}"
    XCTAssertEqual(path.raw, "/api/integrations/{id}")
  }

  func testWithParameters() {
    test("/api/bot/{id}", parameters: ["id": "123"], expected: "/api/bot/123")
    test("/api/bot/{id}", parameters: ["invalid_id": "123"], expected: "/api/bot/{id}")
    test("/api/bot/{}", parameters: ["id": "123"], expected: "/api/bot/{}")
  }
}

extension PathTests {
  func test(_ pattern: String, parameters: [String: RawRequestValueConvertible]? = nil, expected: String) {
    let path = Request.Path(pattern: pattern, parameters: parameters)
    XCTAssertEqual(path.raw, expected)
  }
}
