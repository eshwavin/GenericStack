//
//  CollectionViewSection.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

final public class CollectionViewSection {
    let header: CollectionViewHeaderFooterConfiguratorProtocol?
    var cellConfigurators: [CellConfiguratorProtocol]
    let footer: CollectionViewHeaderFooterConfiguratorProtocol?
    
    init(header: CollectionViewHeaderFooterConfiguratorProtocol? = nil, cellConfigurators: [CellConfiguratorProtocol], footer: CollectionViewHeaderFooterConfiguratorProtocol? = nil) {
        self.header = header
        self.cellConfigurators = cellConfigurators
        self.footer = footer
    }
}

