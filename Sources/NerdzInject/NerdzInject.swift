
public final class NerdzInject {
    private typealias RegistrationInfo = (isSingleton: Bool, closure: () -> Any)
    
    private var registrations: [String: RegistrationInfo] = [:]
    
    // MARK: - Singleton
    
    public static let shared = NerdzInject()
    
    private init() { }
    
    // MARK: - Regiastering(Object)
    
    public func register<T>(object: T) {
        register(closure: { object })
    }
    
    public func register<T, V>(object: T, for type: V.Type) {
        register(for: type) { object }
    }
    
    public func register<T>(object: T, for identifier: String) {
        register(for: identifier) { object }
    }
    
    // MARK: - Registering(Closure)
    
    public func register<T>(singleton: Bool = false, closure: @escaping () -> T) {
        register(for: T.self, closure: closure)
    }
    
    public func register<T, V>(singleton: Bool = false, for type: V.Type, closure: @escaping () -> T) {
        let identifier = String(describing: V.self)
        register(for: identifier, closure: closure)
    }
    
    public func register<T>(singleton: Bool = false, for identifier: String, closure: @escaping () -> T) {
        registrations[identifier] = (singleton, closure: closure)
    }
    
    // MARK: - Resolving
    
    public func resolve<T>() -> T? {
        let identifier = String(describing: T.self)
        return resolve(by: identifier)
    }
    
    public func resolve<T, V>(by type: V.Type) -> T? {
        let identifier = String(describing: V.self)
        return resolve(by: identifier)
    }
    
    public func resolve<T>(by identifier: String) -> T? {
        guard let info = registrations[identifier] else {
            return nil
        }
        
        guard let instance = info.closure() as? T else {
            return nil
        }
        
        if info.isSingleton {
            remove(by: identifier)
            register(object: instance, for: identifier)
        }
        
        return instance
    }
    
    // MARK: - Force Resolving
    
    public func forceRespolve<T>() -> T {
        resolve()!
    }
    
    public func forceResolve<T, V>(by type: V.Type) -> T {
        resolve(by: type)!
    }
    
    public func forceResolve<T>(by identifier: String) -> T {
        resolve(by: identifier)!
    }
    
    // MARK: - Removing

    @discardableResult
    public func remove(by identifier: String) -> Bool {
        registrations.removeValue(forKey: identifier) != nil
    }
    
    @discardableResult
    public func remove<T>(by type: T.Type) -> Bool {
        let identifier = String(describing: T.self)
        return remove(by: identifier)
    }
}
