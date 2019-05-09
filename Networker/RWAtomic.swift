import Foundation

public final class RWAtomic<Value> {
  public typealias Value = Value

  private let queue = DispatchQueue(label: "Read Write Atomic",
                                    attributes: .concurrent)
  private var _value: Value

  public init(_ value: Value) {
    _value = value
  }

  public var value: Value {
    return queue.sync { self._value }
  }

  public func mutate(_ transform: @escaping (inout Value) -> Void) {
    queue.async {
      transform(&self._value)
    }
  }
}
