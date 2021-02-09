//
//  CollectionViewHeaderFooterProtocol.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol CollectionViewHeaderFooterConfiguratorProtocol {
    var reuseID: String { get }
    var height: CGFloat? { get }
    func configure(headerFooterView: UIView)
}

final class CollectionViewHeaderFooterConfigurator<HeaderFooter: ConfigurableView, Model>: CollectionViewHeaderFooterConfiguratorProtocol where HeaderFooter.Model == Model {
    
    var reuseID: String {
        return String(describing: HeaderFooter.self)
    }
    
    let model: Model?
    let height: CGFloat?
    let completeConfiguration: ((HeaderFooter) -> ())?
    
    init(model: Model?, height: CGFloat? = nil, _ completeConfiguration: ((_ headerFooter: HeaderFooter) -> ())? = nil) {
        self.model = model
        self.height = height
        self.completeConfiguration = completeConfiguration
    }
    
    func configure(headerFooterView: UIView) {
        completeConfiguration?(headerFooterView as! HeaderFooter)
        guard let model = model else { return }
        (headerFooterView as! HeaderFooter).configure(with: model)
    }
}

