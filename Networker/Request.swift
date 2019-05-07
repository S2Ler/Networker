import Foundation

public protocol ResponseDecoder {
  associatedtype ErrorType: Swift.Error
  static func decode<T: Decodable>(_ type: T.Type, data: Data?, response: URLResponse?, error: Error?) -> Result<T, ErrorType>
}

public struct Request<Success: Decodable, Decoder: ResponseDecoder> {
  public var baseUrl: URL
  public var path: RequestPath
  public var urlParams: [String: RawRequestValueConvertible?]?
  public var httpMethod: HttpMethod
  public var body: RequestBody?
  public var headers: [String: RawRequestValueConvertible]?
  public var timeout: TimeInterval = 60
  public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy

  public static func convert(data: Data?,
                             response: URLResponse?,
                             error: Error?) -> Result<Success, Decoder.ErrorType> {
    return Decoder.decode(Success.self, data: data, response: response, error: error)
  }
}

public extension Request {
  enum URLError: Swift.Error {
    case invalidUrl(baseUrl: URL, RequestPath)
  }

  /// - throws: URLError.badURL
  func url() -> Result<URL, URLError> {
    guard var urlComponents = URLComponents(url: baseUrl.appendingPathComponent(path.raw),
                                            resolvingAgainstBaseURL: false) else {
      return .failure(.invalidUrl(baseUrl: baseUrl, path))
    }

    urlComponents.queryItems = urlParams?.map { (args) -> URLQueryItem in
      let (key, value) = args
      return URLQueryItem(name: key, value: value?.rawRequestValue)
    }

    guard let url = urlComponents.url else {
      return .failure(.invalidUrl(baseUrl: baseUrl, path))
    }

    return .success(url)
  }
}
