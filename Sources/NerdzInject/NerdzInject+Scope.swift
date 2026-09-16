public extension NerdzInject {

    /// Runs `operation` with ``current`` bound to a fresh, isolated container
    /// that `configure` registers dependencies into. This is the primary test
    /// entry point. A type constructed inside `operation` captures this
    /// container, so an override sticks to it even after `operation` returns.
    ///
    /// ```swift
    /// NerdzInject.withDependencies {
    ///     $0.registerObject(spy, for: ProfileRepository.self)
    /// } operation: {
    ///     let sut = ProfileViewModel()
    ///     sut.load()
    /// }
    /// ```
    /// - Parameters:
    ///   - configure: A closure that registers dependencies into the fresh container.
    ///   - operation: The work to run with the container bound to ``current``.
    /// - Returns: The value returned by `operation`.
    @discardableResult
    static func withDependencies<R>(
        _ configure: (NerdzInject) -> Void,
        operation: () throws -> R
    ) rethrows -> R {
        let container = NerdzInject()
        configure(container)
        return try $current.withValue(container, operation: operation)
    }

    /// The asynchronous form of ``withDependencies(_:operation:)``.
    /// - Parameters:
    ///   - configure: A closure that registers dependencies into the fresh container.
    ///   - operation: The asynchronous work to run with the container bound to ``current``.
    /// - Returns: The value returned by `operation`.
    @discardableResult
    static func withDependencies<R>(
        _ configure: (NerdzInject) -> Void,
        operation: () async throws -> R
    ) async rethrows -> R {
        let container = NerdzInject()
        configure(container)
        return try await $current.withValue(container, operation: operation)
    }

    /// Runs `perform` with ``current`` bound to a container you built yourself.
    /// - Parameters:
    ///   - container: The container to bind to ``current`` for the scope.
    ///   - perform: The work to run with the container bound to ``current``.
    /// - Returns: The value returned by `perform`.
    static func withContainer<R>(_ container: NerdzInject, perform: () throws -> R) rethrows -> R {
        try $current.withValue(container, operation: perform)
    }

    /// The asynchronous form of ``withContainer(_:perform:)``.
    /// - Parameters:
    ///   - container: The container to bind to ``current`` for the scope.
    ///   - perform: The asynchronous work to run with the container bound to ``current``.
    /// - Returns: The value returned by `perform`.
    static func withContainer<R>(_ container: NerdzInject, perform: () async throws -> R) async rethrows -> R {
        try await $current.withValue(container, operation: perform)
    }
}
