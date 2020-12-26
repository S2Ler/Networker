import Foundation

@propertyWrapper
public final class RWAtomic<Value> {
  public typealias Value = Value
  
  private var lock: pthread_rwlock_t
  private var _value: Value
  
  public init(wrappedValue initialValue: Value) {
    _value = initialValue
    lock = pthread_rwlock_t()
    pthread_rwlock_init(&lock, nil)
  }
  
  deinit {
    pthread_rwlock_destroy(&lock)
  }
  
  public var wrappedValue: Value {
    get {
      pthread_rwlock_rdlock(&lock); defer {
        pthread_rwlock_unlock(&lock)
      }
      return _value
    }
    set {
      pthread_rwlock_rdlock(&lock); defer {
        pthread_rwlock_unlock(&lock)
      }
      _value = newValue
    }
  }
  
  public func mutate(_ mutation: (inout Value) throws -> Void) rethrows {
    pthread_rwlock_wrlock(&lock); defer {
      pthread_rwlock_unlock(&lock)
    }
    try mutation(&_value)
  }
}
