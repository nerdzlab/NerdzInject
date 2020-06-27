//
//  Inject.swift
//  NerdzInject
//
//  Created by new user on 26.06.2020.
//

import Foundation

@propertyWrapper 
class Inject<T> {
    
    private let identifier: String
    private let allowRegister: Bool
    
    var wrappedValue: T? {
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
    
    init(_ identifier: String, allowRegister: Bool = false) {
        self.identifier = identifier
        self.allowRegister = allowRegister
    }
    
    convenience init<V>(_ type: V.Type, allowRegister: Bool = false) {
        let identifier = String(describing: V.self)
        self.init(identifier, allowRegister: allowRegister)
    }
    
    convenience init(allowRegister: Bool = false) {
        let identifier = String(describing: T.self)
        self.init(identifier, allowRegister: allowRegister)
    }
} 
