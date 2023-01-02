import Combine
import ComposableArchitecture
import Foundation

public protocol ComposableCoreProtocol {
  associatedtype State
  associatedtype Action
  var store: ComposableArchitecture.Store<State, Action>? { get }
  var viewStore: ComposableArchitecture.ViewStore<State, Action>? { get }
}

extension ComposableCoreProtocol {
  public typealias Store = ComposableArchitecture.Store<State, Action>
  public typealias ViewStore = ComposableArchitecture.ViewStore<State, Action>
  public typealias Cancellables = Set<AnyCancellable>
}

/// Protocol that enables you to use composable core and provides convenient typealiases for it
public protocol ComposableCoreProvider {
  associatedtype State
  associatedtype Action

  var core: ComposableCore<State, Action> { get }
}

extension ComposableCoreProvider {
  public typealias Core = ComposableCore<State, Action>

  @inlinable
  public func resetCore() {
    core.releaseStore()
  }
}

public protocol CoreResetable {
  @inlinable
  func resetCore()
}

public protocol ComposableObjectProtocol:
  NSObject,
  ComposableCoreProvider,
  CoreResetable
{
  @inlinable
  func scope(_ store: Core.Store?)

  @inlinable
  func storeWillSet(
    from oldStore: Core.Store?,
    to newStore: Core.Store?
  )

  @inlinable
  func storeWasSet(
    from oldStore: Core.Store?,
    to newStore: Core.Store?
  )

  @inlinable
  func bind(
    _ state: Core.StorePublisher,
    into cancellables: inout Core.Cancellables
  )
}

extension ComposableObjectProtocol {
  @inlinable
  public func __setupCore() {
    core.onScope { [weak self] store in
      self?.scope(store)
    }

    core.onStoreWillSet { [weak self] old, new in
      self?.storeWillSet(from: old, to: new)
    }

    core.onStoreDidSet { [weak self] old, new in
      self?.storeWasSet(from: old, to: new)
    }

    core.onBind { [weak self] state, cancellables in
      self?.bind(state, into: &cancellables)
    }
  }
}
