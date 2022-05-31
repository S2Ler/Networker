@testable import Networker
import XCTest

class PluginTests: XCTestCase {
  func testInjectHeaderPlugin() async {
    let finalRequestHandlerCalled = expectation(description: "finalRequestHandler")

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
      _ = try await dispatcher.dispatch(request)
    }
    catch {
      // no-op
    }

    await waitForExpectations(timeout: 1, handler: nil)
  }

  func testInjectHeaderPlugingDynamic() async {
    let finalRequestHandlerCalled = expectation(description: "finalRequestHandler")

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
      _ = try await dispatcher.dispatch(request)
    }
    catch {
      // no-op
    }

    await waitForExpectations(timeout: 1)
  }
}
