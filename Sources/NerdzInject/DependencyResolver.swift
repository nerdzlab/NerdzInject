/// An abstraction over ``NerdzInject`` for constructor based dependency
/// injection.
///
/// Inject `any DependencyResolver` into a type (defaulting to
/// ``NerdzInject/shared``) and pass a test container in tests. This is an
/// alternative to the ``Inject`` and ``ForceInject`` property wrappers for teams
/// that prefer explicit injection.
public protocol DependencyResolver: Sendable {
    /// Resolves an instance by its inferred type.
    func resolve<T>() -> T?
    /// Resolves an instance by a provided type.
    func resolve<T, V>(by type: V.Type) -> T?
    /// Resolves an instance by a string identifier.
    func resolve<T>(by identifier: String) -> T?
    /// Force resolves an instance by its inferred type.
    func forceResolve<T>() -> T
    /// Force resolves an instance by a provided type.
    func forceResolve<T, V>(by type: V.Type) -> T
    /// Force resolves an instance by a string identifier.
    func forceResolve<T>(by identifier: String) -> T
}

extension NerdzInject: DependencyResolver { }
