import Combine
import Foundation

public typealias DeferedFuture<Success, Failure: Error> = Publishers.Deferred<Publishers.Future<Success, Failure>>
