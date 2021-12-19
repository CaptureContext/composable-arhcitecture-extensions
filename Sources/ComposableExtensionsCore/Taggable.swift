public protocol Taggable {
  associatedtype Tag: Hashable
  var tag: Tag { get }
}

extension Optional: Taggable where Wrapped: Taggable {
  public typealias Tag = Optional<Wrapped.Tag>
  public var tag: Tag { self?.tag }
}

/// A wrapper around a value and a hashable identifier that conforms to identifiable.
@dynamicMemberLookup
public struct Tagged<Tag, Value>: Taggable where Tag: Hashable {
  public let tag: Tag
  public var value: Value
  
  /// Initializes an identified value from a given value and a hashable identifier.
  ///
  /// - Parameters:
  ///   - value: A value.
  ///   - id: A hashable identifier.
  public init(_ value: Value, tag: Tag) {
    self.tag = tag
    self.value = value
  }
  
  /// Initializes an identified value from a given value and a function that can return a hashable
  /// identifier from the value.
  ///
  ///    ```swift
  ///     Identified(uuid, id: \.self)
  ///    ```
  ///
  /// - Parameters:
  ///   - value: A value.
  ///   - id: A hashable identifier.
  public init(_ value: Value, tag: (Value) -> Tag) {
    self.init(value, tag: tag(value))
  }
  
  // NB: This overload works around a bug in key path function expressions and `\.self`.
  /// Initializes an identified value from a given value and a function that can return a hashable
  /// identifier from the value.
  ///
  ///    ```swift
  ///     Identified(uuid, id: \.self)
  ///    ```
  ///
  /// - Parameters:
  ///   - value: A value.
  ///   - id: A key path from the value to a hashable identifier.
  public init(_ value: Value, tag: KeyPath<Value, Tag>) {
    self.init(value, tag: value[keyPath: tag])
  }
  
  public subscript<LocalValue>(
    dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
  ) -> LocalValue {
    get { self.value[keyPath: keyPath] }
    set { self.value[keyPath: keyPath] = newValue }
  }
}

extension Tagged: Decodable where Tag: Decodable, Value: Decodable {}
extension Tagged: Encodable where Tag: Encodable, Value: Encodable {}
extension Tagged: Equatable where Value: Equatable {}
extension Tagged: Hashable where Value: Hashable {}