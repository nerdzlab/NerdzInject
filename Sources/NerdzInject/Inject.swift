//
//  Inject.swift
//  NerdzInject
//
//  Created by new user on 26.06.2020.
//

import Foundation

public class BaseInject<T> {
    fileprivate let identifier: String
    fileprivate let allowRegister: Bool
    
    public init(_ identifier: String, allowRegister: Bool = false) {
        self.identifier = identifier
        self.allowRegister = allowRegister
    }
    
    public convenience init<V>(_ type: V.Type, allowRegister: Bool = false) {
        let identifier = String(describing: V.self)
        self.init(identifier, allowRegister: allowRegister)
    }
    
    public convenience init(allowRegister: Bool = false) {
        let identifier = String(describing: T.self)
        self.init(identifier, allowRegister: allowRegister)
    }
}

@propertyWrapper 
public class Inject<T>: BaseInject<T> {
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

@propertyWrapper 
public class ForceInject<T>: BaseInject<T> {
    
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
