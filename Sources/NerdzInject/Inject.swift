import Foundation

/// A property wrapper that resolves an optional instance from ``NerdzInject``.
///
/// The wrapped value resolves lazily from ``NerdzInject/shared`` on every read
/// and is `nil` when nothing is registered for the key. Set `allowRegister` to
/// `true` to register the assigned value on write.
@propertyWrapper public struct Inject<T> {

    private let identifier: String
    private let allowRegister: Bool

    /// Creates a wrapper that resolves by a string identifier.
    /// - Parameters:
    ///   - identifier: The identifier used to resolve the instance.
    ///   - allowRegister: When `true`, assigning a new value registers it into
    ///     ``NerdzInject``. Defaults to `false`.
    public init(_ identifier: String, allowRegister: Bool = false) {
        self.identifier = identifier
        self.allowRegister = allowRegister
    }

    /// Creates a wrapper that resolves by a type.
    /// - Parameters:
    ///   - type: The type used to resolve the instance.
    ///   - allowRegister: When `true`, assigning a new value registers it into
    ///     ``NerdzInject``. Defaults to `false`.
    public init<V>(_ type: V.Type, allowRegister: Bool = false) {
        let identifier = String(describing: V.self)
        self.init(identifier, allowRegister: allowRegister)
    }

    /// Creates a wrapper that resolves by the wrapped type `T`.
    /// - Parameter allowRegister: When `true`, assigning a new value registers
    ///   it into ``NerdzInject``. Defaults to `false`.
    public init(allowRegister: Bool = false) {
        let identifier = String(describing: T.self)
        self.init(identifier, allowRegister: allowRegister)
    }

    /// The resolved instance, or `nil` when nothing is registered for the key.
    ///
    /// Reading resolves from ``NerdzInject/shared``. Writing registers the new
    /// value when `allowRegister` is `true`, and does nothing otherwise.
    public var wrappedValue: T? {
        get {
            NerdzInject.shared.resolve(by: identifier)
        }

        nonmutating set {
            guard allowRegister else {
                return
            }

            NerdzInject.shared.registerObject(newValue, for: identifier)
        }
    }
}

/// A property wrapper that force resolves an instance from ``NerdzInject``.
///
/// The wrapped value resolves lazily from ``NerdzInject/shared`` on every read.
/// Set `allowRegister` to `true` to register the assigned value on write.
///
/// > Warning: Reading the wrapped value crashes when nothing is registered for
/// the key. Use ``Inject`` when a missing registration is possible.
@propertyWrapper public struct ForceInject<T> {

    private let identifier: String
    private let allowRegister: Bool

    /// Creates a wrapper that resolves by a string identifier.
    /// - Parameters:
    ///   - identifier: The identifier used to resolve the instance.
    ///   - allowRegister: When `true`, assigning a new value registers it into
    ///     ``NerdzInject``. Defaults to `false`.
    public init(_ identifier: String, allowRegister: Bool = false) {
        self.identifier = identifier
        self.allowRegister = allowRegister
    }

    /// Creates a wrapper that resolves by a type.
    /// - Parameters:
    ///   - type: The type used to resolve the instance.
    ///   - allowRegister: When `true`, assigning a new value registers it into
    ///     ``NerdzInject``. Defaults to `false`.
    public init<V>(_ type: V.Type, allowRegister: Bool = false) {
        let identifier = String(describing: V.self)
        self.init(identifier, allowRegister: allowRegister)
    }

    /// Creates a wrapper that resolves by the wrapped type `T`.
    /// - Parameter allowRegister: When `true`, assigning a new value registers
    ///   it into ``NerdzInject``. Defaults to `false`.
    public init(allowRegister: Bool = false) {
        let identifier = String(describing: T.self)
        self.init(identifier, allowRegister: allowRegister)
    }

    /// The resolved instance.
    ///
    /// Reading force resolves from ``NerdzInject/shared``. Writing registers the
    /// new value when `allowRegister` is `true`, and does nothing otherwise.
    ///
    /// > Warning: Reading crashes when nothing is registered for the key.
    public var wrappedValue: T {
        get {
            NerdzInject.shared.forceResolve(by: identifier)
        }

        nonmutating set {
            guard allowRegister else {
                return
            }

            NerdzInject.shared.registerObject(newValue, for: identifier)
        }
    }
}
