import Foundation

/// A small cross-platform lock primitive backed by Foundation's `NSLock`.
///
/// `LockedState` guards a piece of mutable `State` so it can be shared safely
/// across isolation domains. Every read and write of `state` is performed while
/// the underlying `lock` is held, which is why this type can vend a checked
/// `Sendable` container to its users.
///
/// - Important: This is the single, confined `@unchecked Sendable` escape hatch
///   in this package. The safety invariant is that **all access to `state` goes
///   through `lock`** via ``withLock(_:)``; there is no other path to the stored
///   value. No other type in this package is allowed to be `@unchecked Sendable`.
final class LockedState<State>: @unchecked Sendable {

    // MARK: - Properties(private)

    private let lock = NSLock()
    private var state: State

    // MARK: - Life cycle

    init(_ initial: State) {
        self.state = initial
    }

    // MARK: - Methods(public)

    /// Executes `body` while holding the lock, giving it exclusive mutable access
    /// to the guarded state.
    /// - Parameter body: A closure that receives the guarded state `inout` and
    ///   returns a result.
    /// - Returns: The value returned by `body`.
    func withLock<R>(_ body: (inout State) -> R) -> R {
        lock.lock()
        defer { lock.unlock() }
        return body(&state)
    }
}
