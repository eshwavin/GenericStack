//
//  Result+Extension.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 26/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}
