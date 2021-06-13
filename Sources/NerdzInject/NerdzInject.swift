/// A class that registers and resolve all the dependencies

public final class NerdzInject {
    private typealias RegistrationInfo = (isSingleton: Bool, closure: () -> Any)
    
    private var registrations: [String: RegistrationInfo] = [:]
    
    // MARK: - Singleton
    
    /// SIngleton instance of a class
    public static let shared = NerdzInject()
    
    private init() { }
    
    // MARK: - Regiastering(Object)
    
    /// Register an object based on instance type
    /// - Parameter object: Registered instance that needs to be resolved later 
    public func register<T>(object: T) {
        register(closure: { object })
    }
    
    /// Register an object for another  type
    /// Might be useful when you want to register child object to be resolved for all parent requests
    /// - Parameters:
    ///   - object: Registered instance that needs to be resolved later 
    ///   - type: A type to what this instance needs to be resolved
    public func register<T, V>(object: T, for type: V.Type) {
        register(for: type) { object }
    }
    
    /// Register an object that might be 
    /// - Parameters:
    ///   - object: Registered instance that needs to be resolved later
    ///   - identifier: Unique dentifier that needs to be used for resolving instance in future
    public func register<T>(object: T, for identifier: String) {
        register(for: identifier) { object }
    }
    
    // MARK: - Registering(Closure)
    
    /// Lazy register of an instance based on instance type
    /// The closure will be called on a moment when resolving is requested for instance type
    /// - Parameters:
    ///   - singleton: If is enabled - instance that will be created after initial resolving, will be cached and used in future instead of creating a new one
    ///   - closure: Closure that needs to create a new instance of a type
    public func register<T>(singleton: Bool = false, closure: @escaping () -> T) {
        register(for: T.self, closure: closure)
    }
    
    /// Lazy register of an instance based on provided type
    /// The closure will be called on a moment when resolving is requested for instance type
    /// - Parameters:
    ///   - singleton: If is enabled - instance that will be created after initial resolving, will be cached and used in future instead of creating a new one
    ///   - type: A type to what this instance needs to be resolved
    ///   - closure: Closure that needs to create a new instance of a type
    public func register<T, V>(singleton: Bool = false, for type: V.Type, closure: @escaping () -> T) {
        let identifier = String(describing: V.self)
        register(for: identifier, closure: closure)
    }
    
    /// Lazy register of an instance based on provided identifier
    /// The closure will be called on a moment when resolving is requested for instance type
    /// - Parameters:
    ///   - singleton: If is enabled - instance that will be created after initial resolving, will be cached and used in future instead of creating a new one
    ///   - identifier: A unique identifier that needs to be used for resolving an instance
    ///   - closure: Closure that needs to create a new instance of a type
    public func register<T>(singleton: Bool = false, for identifier: String, closure: @escaping () -> T) {
        registrations[identifier] = (singleton, closure: closure)
    }
    
    // MARK: - Resolving
    
    /// Resoving an instance based on type
    /// - Returns: Resolved instance if such exist
    public func resolve<T>() -> T? {
        let identifier = String(describing: T.self)
        return resolve(by: identifier)
    }
    
    /// Resolving an instance based on provided type
    /// Return type might differ, for example if you know for sure that under registration type is a child instance 
    /// - Parameter type: A type based on what library needs to resolve an instance
    /// - Returns: Resolved instance if such exist
    public func resolve<T, V>(by type: V.Type) -> T? {
        let identifier = String(describing: V.self)
        return resolve(by: identifier)
    }
    
    /// Resolving an instance based on provided identifier
    /// - Parameter identifier: An identifier that was used during instance registration
    /// - Returns: Resolved instance if such exist
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
    
    /// Force-resoving an instance based on type
    /// - Returns: Resolved instance or crash
    public func forceResolve<T>() -> T {
        resolve()!
    }
    
    /// Resolving an instance based on provided type
    /// Return type might differ, for example if you know for sure that under registration type is a child instance 
    /// - Parameter type: A type based on what library needs to resolve an instance
    /// - Returns: Resolved instance or crash
    public func forceResolve<T, V>(by type: V.Type) -> T {
        resolve(by: type)!
    }
    
    /// Resolving an instance based on provided identifier
    /// - Parameter identifier: An identifier that was used during instance registration
    /// - Returns: Resolved instance or crash
    public func forceResolve<T>(by identifier: String) -> T {
        resolve(by: identifier)!
    }
    
    // MARK: - Removing
    
    /// Removing registered instance if such exist
    /// - Parameter identifier: An identifier with what an instance was registered
    /// - Returns: `true` if removing was successful
    @discardableResult
    public func remove(by identifier: String) -> Bool {
        registrations.removeValue(forKey: identifier) != nil
    }
    
    /// Removing registered instance if such exist
    /// - Parameter type: A type with what an instance was registered
    /// - Returns: `true` if removing was successful
    @discardableResult
    public func remove<T>(by type: T.Type) -> Bool {
        let identifier = String(describing: T.self)
        return remove(by: identifier)
    }
}
