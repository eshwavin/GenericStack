//
//  TimeInterval+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension TimeInterval {
    var time: String {
        return String(format: "%02d", Int(self))
    }
}

