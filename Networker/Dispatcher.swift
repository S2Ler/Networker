import Foundation

public protocol Dispatcher: AnyObject {
  func dispatch<Success, Decoder>(_ request: Request<Success, Decoder>,
                                  completionQueue: DispatchQueue,
                                  completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void)
    where Success: Decodable, Decoder: ResponseDecoder
}

extension URLSession: Dispatcher {
  public func dispatch<Success, Decoder>(_ request: Request<Success, Decoder>,
                                         completionQueue: DispatchQueue,
                                         completion: @escaping (Result<Success, Decoder.ErrorType>) -> Void)
    where Success: Decodable, Decoder: ResponseDecoder
  {
    
  }
}
