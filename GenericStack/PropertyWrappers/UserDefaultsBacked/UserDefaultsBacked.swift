//
//  UserDefaultsBacked.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        self == nil
    }
}

@propertyWrapper struct UserDefaultsBacked<Value> {
    
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard
    
    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            }
            else {
                storage.setValue(newValue, forKey: key)
            }
        }
    }
    
}

extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, storage: storage)
    }
    
}
