//
//  Dictionary+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func asJSONString() throws -> String? {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return String(data: data, encoding: .utf8)
    }
    
    func decode<Object: Decodable>(toType type: Object.Type, decoder: JSONDecoder = JSONDecoder()) throws -> Object? {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return try decoder.decode(Object.self, from: data)
    }
    
}
