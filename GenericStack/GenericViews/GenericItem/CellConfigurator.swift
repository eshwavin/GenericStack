//
//  CellConfigurator.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

@objc public protocol CellConfiguratorProtocol {
    var reuseID: String { get }
    func configure(cell: UIView, at indexPath: IndexPath)
}

final public class CellConfigurator<Cell: ConfigurableView, Model>: CellConfiguratorProtocol where Cell.Model == Model {
    
    public var reuseID: String {
        return String(describing: Cell.self)
    }
    
    let model: Model
    let completeConfiguration: ((Cell, IndexPath) -> ())?
    
    init(model: Model, _ completeConfiguration: ((_ cell: Cell, _ indexPath: IndexPath) -> ())? = nil) {
        self.model = model
        self.completeConfiguration = completeConfiguration
    }
    
    public func configure(cell: UIView, at indexPath: IndexPath) {
        completeConfiguration?(cell as! Cell, indexPath)
        (cell as! Cell).configure(with: model)
    }
    
}

