import Foundation
@testable import Networker

internal class EmptyDecoder: ResponseDecoder {
  enum EmptyError: Swift.Error {
    case empty
  }

  static func decode<T>(_: T.Type, result: Result<(Data, URLResponse), Error>) -> Result<T, Error>
  where T: Decodable
  {
    return .failure(EmptyError.empty)
  }

  typealias ErrorType = EmptyError
}
