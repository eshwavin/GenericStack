//
//  TableViewSection.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

final class TableViewSection {
    let header: TableViewHeaderFooterConfiguratorProtcol?
    var cellConfigurators: [CellConfiguratorProtocol]
    let footer: TableViewHeaderFooterConfiguratorProtcol?
    
    init(header: TableViewHeaderFooterConfiguratorProtcol? = nil, cellConfigurators: [CellConfiguratorProtocol], footer: TableViewHeaderFooterConfiguratorProtcol? = nil) {
        self.header = header
        self.cellConfigurators = cellConfigurators
        self.footer = footer
    }
    
}

