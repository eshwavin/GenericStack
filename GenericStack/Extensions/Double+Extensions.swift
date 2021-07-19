//
//  Double+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toRadian() -> Double {
        return self * .pi * 2
    }
    
    func format(withMaximumFractionalDigits maximumFractionalDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionalDigits
        let number = NSNumber(value: self)
        let formattedValue = formatter.string(from: number)
        
        return formattedValue.isNil ? "\(self)" : "\(formattedValue!)"
    }
}

