
class NerdzInject {
    static let shared = NerdzInject()
    
    private var instances: [String: Any] = [:]
    
    func register<T>(_ object: T) {
        register(object, for: T.self)
    }
    
    func register<T, V>(_ object: T, for class: V.Type) {
        let identifier = String(describing: V.self)
        register(object, for: identifier)
    }
    
    func register<T>(_ object: T, for identifier: String) {
        instances[identifier] = object
    }
    
    func resolve<T>() -> T? {
        let identifier = String(describing: T.self)
        return resolve(for: identifier)
    }
    
    func resolve<T, V>(for type: V.Type) -> T? {
        let identifier = String(describing: V.self)
        return resolve(for: identifier)
    }
    
    func resolve<T>(for identifier: String) -> T? {
        instances[identifier] as? T
    }
}
