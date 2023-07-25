//
//  ConfigurableView.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

public protocol ConfigurableView {
    associatedtype Model
    func configure(with: Model)
}

// TODO: Check if needed
public extension ConfigurableView {
    func configure(with model: AnyObject) {
        
    }
}
