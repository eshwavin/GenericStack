//
//  Future.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

class Future<Value> {
    
    var result: Result<Value, Error>? {
        didSet {
            result.map(report)
        }
    }
    
    private lazy var callbacks = [(Result<Value, Error>) -> Void]()
    
    func observe(with callback: @escaping (Result<Value, Error>) -> Void) {
        callbacks.append(callback)
        result.map(callback)
    }
    
    func report(result: Result<Value, Error>) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
    
}

extension Future {
    
    func chained<NextValue>(with closure: @escaping (Value) throws -> Future<NextValue>) -> Future<NextValue> {
        let promise = Promise<NextValue>()
        
        observe { result in
            switch result {
            case .success(let value):
                do {
                    let future = try closure(value)
                    
                    future.observe { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }
        
        return promise
    }
    
    func transformed<NextValue>(with closure: @escaping (Value) throws -> NextValue) -> Future<NextValue> {
        return chained { value in
            return try Promise(value: closure(value))
        }
    }
    
}

extension Future where Value == Data {
    func decoded<NextValue: Decodable>(toType type: NextValue.Type, decoder: JSONDecoder = JSONDecoder()) -> Future<NextValue> {
        return transformed {
            do {
                return try decoder.decode(NextValue.self, from: $0)
            } catch {
                throw error
            }
        }
    }
    
    func toVoid() -> Future<Void> {
        return transformed { value in
            return ()
        }
    }
    
}
