//
//  Encodable+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension Encodable {
    
    func asDictionary() throws -> [String: Any] {
        return try encodeIntoType()
    }
    
    func asStringValuedDictionary() throws -> [String: String] {
        return try encodeIntoType()
    }
    
    private func encodeIntoType<T>() throws -> [String: T] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: T] else {
            throw NSError()
        }
        return dictionary
    }
    
    func asJSONString(usingEncoder encoder: JSONEncoder = JSONEncoder()) throws -> String? {
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }
    
}

