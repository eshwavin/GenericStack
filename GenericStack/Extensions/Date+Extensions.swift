//
//  Date+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension Date {
    static var defaultFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        return formatter
    }
    
    func stringFromDate(usingFormatter formatter: DateFormatter = Date.defaultFormatter) -> String {
        formatter.string(from: self)
    }
    
    func convert(fromTimeZone initialTimeZone: TimeZone, toTimeZone finalTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(finalTimeZone.secondsFromGMT(for: self) - initialTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}

