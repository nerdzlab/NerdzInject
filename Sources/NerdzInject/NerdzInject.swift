
class NerdzInject {
    private typealias RegistrationInfo = (isSingleton: Bool, closure: () -> Any)
    
    private var registrations: [String: RegistrationInfo] = [:]
    
    // MARK: - Singleton
    
    static let shared = NerdzInject()
    
    private init() { }
    
    // MARK: - Regiastering(Object)
    
    func register<T>(object: T) {
        register(closure: { object })
    }
    
    func register<T, V>(object: T, for type: V.Type) {
        register(for: type) { object }
    }
    
    func register<T>(object: T, for identifier: String) {
        register(for: identifier) { object }
    }
    
    // MARK: - Registering(Closure)
    
    func register<T>(singleton: Bool = false, closure: @escaping () -> T) {
        register(for: T.self, closure: closure)
    }
    
    func register<T, V>(singleton: Bool = false, for type: V.Type, closure: @escaping () -> T) {
        let identifier = String(describing: V.self)
        register(for: identifier, closure: closure)
    }
    
    func register<T>(singleton: Bool = false, for identifier: String, closure: @escaping () -> T) {
        registrations[identifier] = (singleton, closure: closure)
    }
    
    // MARK: - Resolving
    
    func resolve<T>() -> T? {
        let identifier = String(describing: T.self)
        return resolve(by: identifier)
    }
    
    func resolve<T, V>(by type: V.Type) -> T? {
        let identifier = String(describing: V.self)
        return resolve(by: identifier)
    }
    
    func resolve<T>(by identifier: String) -> T? {
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
    
    // MARK: - Removing

    @discardableResult
    func remove(by identifier: String) -> Bool {
        registrations.removeValue(forKey: identifier) != nil
    }
    
    @discardableResult
    func remove<T>(by type: T.Type) -> Bool {
        let identifier = String(describing: T.self)
        return remove(by: identifier)
    }
}
