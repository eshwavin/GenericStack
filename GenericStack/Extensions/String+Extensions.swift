//
//  String+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension String {
    
    func getDate(with format: String, timeZone: TimeZone?) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.date(from: self)
    }
    
    func toDouble() -> Double {
        return Double(self) ?? 0
    }
    
    func asDictionary() throws -> [String: Any]? {
        return try JSONSerialization.jsonObject(with: data(using: .utf8)!, options: .allowFragments) as? [String: Any]
    }
    
}


