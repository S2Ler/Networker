import Foundation
@testable import Networker

internal class EmptyDecoder: ResponseDecoder {
  enum EmptyError: Swift.Error {
    case empty
  }

  static func decode<T>(_: T.Type, data _: Data?, response _: URLResponse?, error _: Error?) -> Result<T, ErrorType> where T: Decodable {
    return .failure(.empty)
  }

  typealias ErrorType = EmptyError
}
