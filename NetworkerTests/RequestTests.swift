@testable import Networker
import XCTest

class RequestTests: XCTestCase {
  private class EmptyDecoder: ResponseDecoder {
    enum EmptyError: Swift.Error {
      case empty
    }

    static func decode<T>(_: T.Type, data _: Data?, response _: URLResponse?, error _: Error?) -> Result<T, ErrorType> where T: Decodable {
      return .failure(.empty)
    }

    typealias ErrorType = EmptyError
  }

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
