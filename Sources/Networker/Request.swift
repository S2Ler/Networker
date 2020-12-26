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
  public var cachePolicy: URLRequest.CachePolicy
  
  public static func convert(data: Data?,
                             response: URLResponse?,
                             error: Error?) -> Result<Success, Decoder.ErrorType> {
    return Decoder.decode(Success.self, data: data, response: response, error: error)
  }
  
  public init(baseUrl: URL,
              path: RequestPath,
              urlParams: [String: RawRequestValueConvertible?]? = nil,
              httpMethod: HttpMethod,
              body: RequestBody? = nil,
              headers: [String: RawRequestValueConvertible]? = nil,
              timeout: TimeInterval = 60,
              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) {
    self.baseUrl = baseUrl
    self.path = path
    self.urlParams = urlParams
    self.httpMethod = httpMethod
    self.body = body
    self.headers = headers
    self.timeout = timeout
    self.cachePolicy = cachePolicy
  }
}

public extension Request {
  var url: URL {
    var urlComponents = path.combine(withBaseUrl: baseUrl)
    
    urlComponents.queryItems = urlParams?.map { (args) -> URLQueryItem in
      let (key, value) = args
      return URLQueryItem(name: key, value: value?.rawRequestValue)
    }
    
    guard let url = urlComponents.url else {
      preconditionFailure("Can't construct url from: \(urlComponents)")
    }
    
    return url
  }
}
