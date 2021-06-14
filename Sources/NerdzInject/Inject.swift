//
//  Inject.swift
//  NerdzInject
//
//  Created by new user on 26.06.2020.
//

import Foundation

/// Property wrapper that automatically resolve instance if such exist
@propertyWrapper public class Inject<T> {
    
    fileprivate let identifier: String
    fileprivate let allowRegister: Bool
    
    /// Initializing with identifier and information if wrapper `set` method needs to be active
    /// - Parameters:
    ///   - identifier: The identifier that needs to be used for resolving
    ///   - allowRegister: If `true` than wrapper `set` method will automatically register `newValue` into `NerdzInject`
    public init(_ identifier: String, allowRegister: Bool = false) {
        self.identifier = identifier
        self.allowRegister = allowRegister
    }
    
    /// Initializing with class type and information if wrapper `set` method needs to be active
    /// - Parameters:
    ///   - type: The instance that needs to be used  for resolving
    ///   - allowRegister: If `true` than wrapper `set` method will automatically register `newValue` into `NerdzInject`
    public convenience init<V>(_ type: V.Type, allowRegister: Bool = false) {
        let identifier = String(describing: V.self)
        self.init(identifier, allowRegister: allowRegister)
    }
    
    /// Initializing with `T` type and information if wrapper `set` method needs to be active
    /// - Parameter allowRegister: If `true` than wrapper `set` method will automatically register `newValue` into `NerdzInject`
    public convenience init(allowRegister: Bool = false) {
        let identifier = String(describing: T.self)
        self.init(identifier, allowRegister: allowRegister)
    }
    
    /// Wrapped value
    public var wrappedValue: T? {
        get {
            NerdzInject.shared.resolve(by: identifier)
        }
        
        set { 
            guard allowRegister else {
                return
            }
            
            NerdzInject.shared.register(object: newValue, for: identifier)
        }
    }
} 

/// Property wrapper that automatically force-resolving instance 
@propertyWrapper public class ForceInject<T> {
    
    fileprivate let identifier: String
    fileprivate let allowRegister: Bool
    
    /// Initializing with identifier and information if wrapper `set` method needs to be active
    /// - Parameters:
    ///   - identifier: The identifier that needs to be used for resolving
    ///   - allowRegister: If `true` than wrapper `set` method will automatically register `newValue` into `NerdzInject`
    public init(_ identifier: String, allowRegister: Bool = false) {
        self.identifier = identifier
        self.allowRegister = allowRegister
    }
    
    /// Initializing with class type and information if wrapper `set` method needs to be active
    /// - Parameters:
    ///   - type: The instance that needs to be used  for resolving
    ///   - allowRegister: If `true` than wrapper `set` method will automatically register `newValue` into `NerdzInject`
    public convenience init<V>(_ type: V.Type, allowRegister: Bool = false) {
        let identifier = String(describing: V.self)
        self.init(identifier, allowRegister: allowRegister)
    }
    
    /// Initializing with `T` type and information if wrapper `set` method needs to be active
    /// - Parameter allowRegister: If `true` than wrapper `set` method will automatically register `newValue` into `NerdzInject`
    public convenience init(allowRegister: Bool = false) {
        let identifier = String(describing: T.self)
        self.init(identifier, allowRegister: allowRegister)
    }
    
    /// Wrapped value
    public var wrappedValue: T {
        get {
            NerdzInject.shared.forceResolve(by: identifier)
        }
        
        set { 
            guard allowRegister else {
                return
            }
            
            NerdzInject.shared.register(object: newValue, for: identifier)
        }
    }
}
