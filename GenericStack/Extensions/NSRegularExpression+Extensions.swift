//
//  NSRegularExpression+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return !(firstMatch(in: string, options: [], range: range).isNil)
    }
    
    static var nonEmptyStringRegularExpression = NSRegularExpression("^(?!\\s*$).+")
    static var emailRegularExpression = NSRegularExpression("^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$")
    
    // For India
    static var phoneRegularExpression = NSRegularExpression("^[0-9]{10}$")
    static var pinCodeRegularExpression = NSRegularExpression("^[1-9]{1}[0-9]{5}$")
    static var bankAccountNumberRegularExpression = NSRegularExpression("[0-9]{9,18}")
    static var ifscCodeRegularExpression = NSRegularExpression("^[A-Z]{4}0[A-Z0-9]{6}$")
    static var panNumberRegularExpression = NSRegularExpression("[A-Z]{5}[0-9]{4}[A-Z]{1}")
}

