//
//  Inject.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Swinject

@propertyWrapper struct Inject<Value> {
    
    public var wrappedValue: Value
    
    public init() {
        self.init(name: nil, resolver: nil)
    }
    
    public init(name: String? = nil, resolver: Resolver? = nil) {
        
        guard let resolver = resolver ?? InjectSettings.resolver else {
            fatalError("Make sure InjectSettings.resolver is set!")
        }
        
        guard let value = resolver.resolve(Value.self, name: name) else {
            fatalError("Could not resolve non-optional \(Value.self)")
        }
        
        wrappedValue = value
    }
    
    public init<Wrapped>(name: String? = nil, resolver: Resolver? = nil) where Value == Optional<Wrapped> {
        guard let resolver = resolver ?? InjectSettings.resolver else {
            fatalError("Make sure InjectSettings.resolver is set!")
        }
        
        wrappedValue = resolver.resolve(Wrapped.self, name: name)
    }
    
}
