/// Runs `operation` with `NerdzInject.current` bound to a fresh, isolated
/// container that `configure` registers dependencies into. This is the primary
/// test entry point. A type constructed inside `operation` captures this
/// container, so an override sticks to it even after `operation` returns.
///
/// ```swift
/// withDependencies {
///     $0.registerObject(spy, for: ProfileRepository.self)
/// } operation: {
///     let sut = ProfileViewModel()
///     sut.load()
/// }
/// ```
/// - Parameters:
///   - configure: A closure that registers dependencies into the fresh container.
///   - operation: The work to run with the container bound to `NerdzInject.current`.
/// - Returns: The value returned by `operation`.
@discardableResult
public func withDependencies<R>(
    _ configure: (NerdzInject) -> Void,
    operation: () throws -> R
) rethrows -> R {
    let container = NerdzInject()
    configure(container)
    return try NerdzInject.$current.withValue(container, operation: operation)
}

/// The asynchronous form of ``withDependencies(_:operation:)``.
/// - Parameters:
///   - configure: A closure that registers dependencies into the fresh container.
///   - operation: The asynchronous work to run with the container bound to `NerdzInject.current`.
/// - Returns: The value returned by `operation`.
@discardableResult
public func withDependencies<R>(
    _ configure: (NerdzInject) -> Void,
    operation: () async throws -> R
) async rethrows -> R {
    let container = NerdzInject()
    configure(container)
    return try await NerdzInject.$current.withValue(container, operation: operation)
}
