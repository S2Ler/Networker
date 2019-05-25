import Foundation

public final class RWAtomic<Value> {
  public typealias Value = Value

  private var lock: pthread_rwlock_t
  private var _value: Value

  public init(_ value: Value) {
    _value = value
    lock = pthread_rwlock_t()
    pthread_rwlock_init(&lock, nil)
  }

  deinit {
    pthread_rwlock_destroy(&lock)
  }

  public var value: Value {
    pthread_rwlock_rdlock(&lock); defer {
      pthread_rwlock_unlock(&lock)
    }
    return _value
  }

  public func mutate(_ transform: (inout Value) -> Void) {
    pthread_rwlock_wrlock(&lock); defer {
      pthread_rwlock_unlock(&lock)
    }
    transform(&_value)
  }
}
