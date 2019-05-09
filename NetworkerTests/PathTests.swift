@testable import Networker
import XCTest

class PathTests: XCTestCase {
  func testRawPath() {
    test("/api/bots", expected: "/api/bots")
  }

  func testExpressibleByStringLiteral() {
    let path: RequestPath = "/api/integrations"
    XCTAssertEqual(path.raw, "/api/integrations")
  }

  func testExpressibleByStringLiteralIgnoresParameters() {
    let path: RequestPath = "/api/integrations/{id}"
    XCTAssertEqual(path.raw, "/api/integrations/{id}")
  }

  func testWithParameters() {
    test("/api/bot/{id}", parameters: ["id": "123"], expected: "/api/bot/123")
    test("/api/bot/{id}", parameters: ["invalid_id": "123"], expected: "/api/bot/{id}")
    test("/api/bot/{}", parameters: ["id": "123"], expected: "/api/bot/{}")
  }

  func testThrowingPatternWithoutLeadingSlash() {
    testThrowing("api/bot/{id}", parameters: ["id": "123"], expectedError: RequestPath.Error.patternWithoutLeadingSlash)
  }
}

extension PathTests {
  func test(_ pattern: StaticString, parameters: [String: RawRequestValueConvertible]? = nil, expected: String) {
    let path = RequestPath(pattern: pattern, parameters: parameters)
    XCTAssertEqual(path.raw, expected)
  }

  func testThrowing(_ pattern: StaticString, parameters: [String: RawRequestValueConvertible]? = nil, expectedError: RequestPath.Error) {
    do {
      _ = try RequestPath(dynamicPattern: pattern.description, parameters: parameters)
      XCTFail()
    } catch let error as RequestPath.Error {
      XCTAssertEqual(expectedError, error)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}
