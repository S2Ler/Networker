import Foundation

@propertyWrapper
public final class RWAtomic<Value> {
  public typealias Value = Value

  private var lock: pthread_rwlock_t
  private var _value: Value

  public init(initialValue: Value) {
    _value = initialValue
    lock = pthread_rwlock_t()
    pthread_rwlock_init(&lock, nil)
  }

  deinit {
    pthread_rwlock_destroy(&lock)
  }

  public var wrappedValue: Value {
    _read {
      pthread_rwlock_rdlock(&lock); defer {
        pthread_rwlock_unlock(&lock)
      }
      yield _value
    }
    _modify {
      pthread_rwlock_rdlock(&lock); defer {
        pthread_rwlock_unlock(&lock)
      }
      yield &_value
    }
  }

  public func mutate(_ transform: (inout Value) -> Void) {
    pthread_rwlock_wrlock(&lock); defer {
      pthread_rwlock_unlock(&lock)
    }
    transform(&_value)
  }
}
