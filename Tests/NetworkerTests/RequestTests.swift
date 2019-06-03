@testable import Networker
import XCTest

class RequestTests: XCTestCase {
  func testUrlExtraction() throws {
    let request: Request<String, EmptyDecoder> = Request(baseUrl: URL(string: "https://server.local")!,
                                                         path: "/api/bot",
                                                         urlParams: nil,
                                                         httpMethod: .get,
                                                         body: nil,
                                                         headers: nil,
                                                         timeout: 60,
                                                         cachePolicy: .useProtocolCachePolicy)
    XCTAssertEqual(request.url.absoluteString, "https://server.local/api/bot")
  }

  func testUrlWithInvalidChars() {
    let request: Request<String, EmptyDecoder> = Request(baseUrl: URL(string: "https://server.local")!,
                                                         path: RequestPath(pattern: "/api/bot%/{id}",
                                                                           parameters: ["id": "%"]),
                                                         urlParams: nil,
                                                         httpMethod: .get,
                                                         body: nil,
                                                         headers: nil,
                                                         timeout: 60,
                                                         cachePolicy: .useProtocolCachePolicy)
    XCTAssertEqual(request.url.absoluteString, "https://server.local/api/bot%25/%25")
  }
}
