//
//  Data+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension Data {
    var sizeInMB: Double {
        return Double(count) / 1000000.0
    }
}

