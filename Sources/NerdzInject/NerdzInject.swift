/// A container that registers and resolves dependencies across an app.
///
/// `NerdzInject` stores registration closures in a registry guarded by a lock
/// and hands back instances on demand. Register a value by its inferred type,
/// by an explicit type, or by a string identifier, then read it back with
/// ``resolve()``, ``forceResolve()``, or the ``Inject`` and ``ForceInject``
/// property wrappers.
///
/// Use the shared registry through ``shared``.
public final class NerdzInject: Sendable {
    private typealias RegistrationInfo = (isSingleton: Bool, closure: () -> Any)

    // The registry is guarded by `LockedState`, which is the only synchronization
    // primitive in this package. Because this is an immutable `let` holding a
    // `Sendable` value, `NerdzInject` is checked `Sendable` with no `@unchecked`.
    private let registrations = LockedState<[String: RegistrationInfo]>([:])

    // MARK: - Singleton

    /// The shared registry used throughout an app.
    ///
    /// Register and resolve dependencies through this instance. Unless a scope
    /// overrides ``current``, the ``Inject`` and ``ForceInject`` property
    /// wrappers resolve against this same registry.
    public static let shared = NerdzInject()

    /// The container the property wrappers capture when they are initialized.
    ///
    /// Defaults to ``shared``. Override it for a scope with
    /// ``withDependencies(_:operation:)`` or ``withContainer(_:perform:)`` so a
    /// unit test can resolve from an isolated container without mutating global
    /// state.
    @TaskLocal public static var current: NerdzInject = shared

    /// Creates an empty container.
    ///
    /// Use this to build an isolated container, typically in a test.
    public init() { }

    // MARK: - Registering(Object)

    /// Registers an existing object, resolvable by its own type.
    /// - Parameter object: The instance to store for later resolution.
    /// - Returns: The same `object`, so the call can be chained or assigned.
    @discardableResult
    public func registerObject<T>(_ object: T) -> T {
        register(closure: { object })
        return object
    }

    /// Registers an existing object, resolvable by another type.
    ///
    /// Useful when a child instance should be resolved for every request of a
    /// parent type.
    /// - Parameters:
    ///   - object: The instance to store for later resolution.
    ///   - type: The type this instance resolves for.
    /// - Returns: The same `object`, so the call can be chained or assigned.
    @discardableResult
    public func registerObject<T, V>(_ object: T, for type: V.Type) -> T {
        register(for: type) { object }
        return object
    }

    /// Registers an existing object, resolvable by a string identifier.
    /// - Parameters:
    ///   - object: The instance to store for later resolution.
    ///   - identifier: A unique identifier used to resolve the instance later.
    /// - Returns: The same `object`, so the call can be chained or assigned.
    @discardableResult
    public func registerObject<T>(_ object: T, for identifier: String) -> T {
        register(for: identifier) { object }
        return object
    }

    // MARK: - Registering(Closure)

    /// Lazily registers a factory, resolvable by its inferred type.
    ///
    /// The closure runs the first time the instance is resolved, not when it is
    /// registered.
    /// - Parameters:
    ///   - singleton: When `true`, the instance built on first resolution is
    ///     cached and reused for later resolutions of the same key.
    ///   - closure: A factory that creates a new instance of the type.
    public func register<T>(singleton: Bool = false, closure: @escaping () -> T) {
        register(singleton: singleton, for: T.self, closure: closure)
    }

    /// Lazily registers a factory, resolvable by a provided type.
    ///
    /// The closure runs the first time the instance is resolved, not when it is
    /// registered.
    /// - Parameters:
    ///   - singleton: When `true`, the instance built on first resolution is
    ///     cached and reused for later resolutions of the same key.
    ///   - type: The type this instance resolves for.
    ///   - closure: A factory that creates a new instance of the type.
    public func register<T, V>(singleton: Bool = false, for type: V.Type, closure: @escaping () -> T) {
        let identifier = String(describing: V.self)
        register(singleton: singleton, for: identifier, closure: closure)
    }

    /// Lazily registers a factory, resolvable by a string identifier.
    ///
    /// The closure runs the first time the instance is resolved, not when it is
    /// registered.
    /// - Parameters:
    ///   - singleton: When `true`, the instance built on first resolution is
    ///     cached and reused for later resolutions of the same key.
    ///   - identifier: A unique identifier used to resolve the instance later.
    ///   - closure: A factory that creates a new instance of the type.
    public func register<T>(singleton: Bool = false, for identifier: String, closure: @escaping () -> T) {
        registrations.withLock { $0[identifier] = (singleton, closure: closure) }
    }

    // MARK: - Resolving

    /// Resolves an instance by its inferred type.
    /// - Returns: The registered instance, or `nil` when nothing is registered
    ///   for the type.
    public func resolve<T>() -> T? {
        let identifier = String(describing: T.self)
        return resolve(by: identifier)
    }

    /// Resolves an instance by a provided type.
    ///
    /// The returned type may differ from `type`, for example when the registered
    /// value is a child of the requested type.
    /// - Parameter type: The type to resolve an instance for.
    /// - Returns: The registered instance, or `nil` when nothing is registered
    ///   for the type.
    public func resolve<T, V>(by type: V.Type) -> T? {
        let identifier = String(describing: V.self)
        return resolve(by: identifier)
    }

    /// Resolves an instance by a string identifier.
    /// - Parameter identifier: The identifier used when the instance was
    ///   registered.
    /// - Returns: The registered instance, or `nil` when nothing is registered
    ///   for the identifier.
    public func resolve<T>(by identifier: String) -> T? {
        // The factory closure is run OUTSIDE the lock, because `NSLock` is not
        // recursive and a user factory may itself resolve dependencies. A benign
        // race is possible on first resolve of a singleton (two callers may each
        // build an instance), but that is acceptable: subsequent resolves are
        // memoized to the winner's instance.
        let info = registrations.withLock { $0[identifier] }

        guard let info else {
            return nil
        }

        guard let instance = info.closure() as? T else {
            return nil
        }

        if info.isSingleton {
            registrations.withLock { $0[identifier] = (isSingleton: false, closure: { instance }) }
        }

        return instance
    }

    // MARK: - Force Resolving

    /// Resolves an instance by its inferred type, trapping when none exists.
    ///
    /// > Warning: This method crashes when nothing is registered for the type.
    /// Prefer ``resolve()`` when a missing registration is possible.
    /// - Returns: The registered instance.
    public func forceResolve<T>() -> T {
        resolve()!
    }

    /// Resolves an instance by a provided type, trapping when none exists.
    ///
    /// The returned type may differ from `type`, for example when the registered
    /// value is a child of the requested type.
    ///
    /// > Warning: This method crashes when nothing is registered for the type.
    /// Prefer ``resolve(by:)-(V.Type)`` when a missing registration is possible.
    /// - Parameter type: The type to resolve an instance for.
    /// - Returns: The registered instance.
    public func forceResolve<T, V>(by type: V.Type) -> T {
        resolve(by: type)!
    }

    /// Resolves an instance by a string identifier, trapping when none exists.
    ///
    /// > Warning: This method crashes when nothing is registered for the
    /// identifier. Prefer ``resolve(by:)-(String)`` when a missing registration
    /// is possible.
    /// - Parameter identifier: The identifier used when the instance was
    ///   registered.
    /// - Returns: The registered instance.
    public func forceResolve<T>(by identifier: String) -> T {
        resolve(by: identifier)!
    }

    // MARK: - Removing

    /// Removes the registration for an identifier, when one exists.
    /// - Parameter identifier: The identifier used when the instance was
    ///   registered.
    /// - Returns: `true` when a registration was removed, `false` otherwise.
    @discardableResult
    public func remove(by identifier: String) -> Bool {
        registrations.withLock { $0.removeValue(forKey: identifier) != nil }
    }

    /// Removes the registration for a type, when one exists.
    /// - Parameter type: The type used when the instance was registered.
    /// - Returns: `true` when a registration was removed, `false` otherwise.
    @discardableResult
    public func remove<T>(by type: T.Type) -> Bool {
        let identifier = String(describing: T.self)
        return remove(by: identifier)
    }
}
