import Foundation

public final class Atomic<Value> {
  public typealias Value = Value

  private let queue = DispatchQueue(label: "Atomic serial queue")
  private var _value: Value

  public init(_ value: Value) {
    _value = value
  }

  public var value: Value {
    return queue.sync { self._value }
  }

  public func mutate(_ transform: (inout Value) -> Void) {
    queue.sync {
      transform(&self._value)
    }
  }
}
