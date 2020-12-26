@testable import Networker
import XCTest

class PluginTests: XCTestCase {
  func testInjectHeaderPlugin() {
    let finalRequestHandlerCalled = expectation(description: "finalRequestHandler")

    runAsyncAndBlock {
      let headerName = "API_VERSION"
      let headerValue = "1.0"

      let dispatcher = MockDispatcher(finalRequestHandler: { urlRequest in
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: headerName), headerValue)
        finalRequestHandlerCalled.fulfill()
      })

      dispatcher.add(InjectHeaderPlugin(headerField: headerName, value: headerValue))

      let request = Request<String, EmptyDecoder>(baseUrl: .anyUrl,
                                                  path: "/api",
                                                  urlParams: nil,
                                                  httpMethod: .get,
                                                  body: nil,
                                                  headers: nil,
                                                  timeout: 60,
                                                  cachePolicy: .useProtocolCachePolicy)
      do {
        _ = await try dispatcher.dispatch(request)
      }
      catch {
        // no-op
      }
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testInjectHeaderPlugingDynamic() {
    let finalRequestHandlerCalled = expectation(description: "finalRequestHandler")

    runAsyncAndBlock {
      let headerName = "API_VERSION"
      let headerValue: () -> String = { "1.0" }

      let dispatcher = MockDispatcher(finalRequestHandler: { urlRequest in
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: headerName), headerValue())
        finalRequestHandlerCalled.fulfill()
      })

      dispatcher.add(InjectHeaderPlugin(headerField: headerName, dynamicValue: headerValue))

      let request = Request<String, EmptyDecoder>(baseUrl: .anyUrl,
                                                  path: "/api",
                                                  urlParams: nil,
                                                  httpMethod: .get,
                                                  body: nil,
                                                  headers: nil,
                                                  timeout: 60,
                                                  cachePolicy: .useProtocolCachePolicy)
      do {
        _ = await try dispatcher.dispatch(request)
      }
      catch {
        // no-op
      }
    }

    waitForExpectations(timeout: 1, handler: nil)
  }
}
