//
//  TableViewHeaderFooterConfigurator.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol TableViewHeaderFooterConfiguratorProtocol {
    var reuseID: String { get }
    var height: CGFloat { get }
    func configure(headerFooterView: UIView, at section: Int)
}

final class TableViewHeaderFooterConfigurator<HeaderFooter: ConfigurableView, Model>: TableViewHeaderFooterConfiguratorProtocol where HeaderFooter.Model == Model {
    
    var reuseID: String { return String(describing: HeaderFooter.self) }
    
    let model: Model?
    let height: CGFloat
    let completeConfiguration: ((HeaderFooter, Int) -> ())?
    
    init(model: Model?, height: CGFloat, _ completeConfiguration: ((_ headerFooter: HeaderFooter, _ section: Int) -> ())? = nil) {
        self.model = model
        self.height = height
        self.completeConfiguration = completeConfiguration
    }
    
    func configure(headerFooterView: UIView, at section: Int) {
        completeConfiguration?(headerFooterView as! HeaderFooter, section)
        guard let model = model else { return }
        (headerFooterView as! HeaderFooter).configure(with: model)
    }
    
    
}

