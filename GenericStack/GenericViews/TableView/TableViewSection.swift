//
//  TableViewSection.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

final class TableViewSection {
    let header: TableViewHeaderFooterConfiguratorProtocol?
    var cellConfigurators: [CellConfiguratorProtocol]
    let trailingSwipeActionsConfiguration: UISwipeActionsConfiguration?
    let footer: TableViewHeaderFooterConfiguratorProtocol?
    
    init(header: TableViewHeaderFooterConfiguratorProtocol? = nil, cellConfigurators: [CellConfiguratorProtocol], trailingSwipeActionsConfiguration: UISwipeActionsConfiguration? = nil, footer: TableViewHeaderFooterConfiguratorProtocol? = nil) {
        self.header = header
        self.cellConfigurators = cellConfigurators
        self.trailingSwipeActionsConfiguration = trailingSwipeActionsConfiguration
        self.footer = footer
    }
}

