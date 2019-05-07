import Foundation

public protocol ResponseDecoder {
  associatedtype ErrorType: Swift.Error
  func decode<T: Decodable>(_ type: T.Type, data: Data?, response: URLResponse?, error: Error?) -> Result<T, ErrorType>
}

public struct Request<Success: Decodable, Decoder: ResponseDecoder> {
  public var path: RequestPath
  public var urlParams: [String: RawRequestValueConvertible]?
  public var httpMethod: HttpMethod
  public var body: RequestBody?
  public var headers: [String: RawRequestValueConvertible]?

  public static func convert(decoder: Decoder,
                             data: Data?,
                             response: URLResponse?,
                             error: Error?) -> Result<Success, Decoder.ErrorType> {
    return decoder.decode(Success.self, data: data, response: response, error: error)
  }
}
