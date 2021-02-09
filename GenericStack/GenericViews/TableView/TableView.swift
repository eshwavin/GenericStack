//
//  TableView.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

@objc protocol TableViewDelegate: class {
    @objc optional func didSelectRow(with item: CellConfiguratorProtocol)
    @objc optional func didPullToRefresh()
    @objc optional func shouldSelectRow(at indexPath: IndexPath) -> Bool
}

final class TableView: UIView {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = separatorStyle
        return tableView
    }()
    
    private var items: [TableViewSection] = [] {
        didSet {
            endRefreshing()
        }
    }
    
    private var filteredItems: [TableViewSection] = [] {
        didSet {
            endRefreshing()
        }
    }
    private var isFilteringEnabled: Bool = false
    
    private lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    
    private let autoDeselectsOnSelection: Bool
    
    // MARK: Settable Properties
    
    weak var delegate: TableViewDelegate?
    
    var supportsPullToRefresh: Bool = false {
        didSet {
            if supportsPullToRefresh {
                tableView.refreshControl = refreshControl
                refreshControl.addTarget(delegate, action: #selector(delegate?.didPullToRefresh), for: .valueChanged)
            }
            else {
                tableView.refreshControl = nil
                refreshControl.removeTarget(delegate, action: #selector(delegate?.didPullToRefresh), for: .valueChanged)
            }
        }
    }
    
    var separatorStyle: UITableViewCell.SeparatorStyle = .none {
        didSet {
            tableView.separatorStyle = separatorStyle
        }
    }
    
    var allowsMultipleSelection: Bool = false {
        didSet {
            tableView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    var allowsSelection: Bool = true {
        didSet {
            tableView.allowsSelection = allowsSelection
        }
    }
    
    var interSectionSpacing: CGFloat? {
        didSet {
            tableView.reloadData()
            endRefreshing()
        }
    }
    
    var followsReadableWidth: Bool = false {
        didSet {
            tableView.cellLayoutMarginsFollowReadableWidth = followsReadableWidth
            tableView.reloadData()
            endRefreshing()
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            tableView.contentInset = contentInset
        }
    }
    
    // MARK: Lifecycle
    init(tableViewDataSource: UITableViewDataSource? = nil, tableViewDelegate: UITableViewDelegate? = nil, autoDeselectsOnSelection: Bool = true) {
        self.autoDeselectsOnSelection = autoDeselectsOnSelection
        super.init(frame: .zero)
        layoutUI()
        tableView.dataSource = tableViewDataSource == nil ? self : tableViewDataSource
        tableView.delegate = tableViewDelegate == nil ? self : tableViewDelegate
    }
    
    required init?(coder: NSCoder) {
        self.autoDeselectsOnSelection = true
        super.init(coder: coder)
        layoutUI()
        tableView.delegate = self
    }
    
    private func layoutUI() {
        addSubview(tableView)
        tableView.pinAllEdges()
        tableView.layoutIfNeeded()
    }
    
    // MARK: Helpers
    
    private func item(at indexPath: IndexPath) -> CellConfiguratorProtocol {
        return isFilteringEnabled ? filteredItems[indexPath.section].cellConfigurators[indexPath.row] : items[indexPath.section].cellConfigurators[indexPath.row]
    }
    
    // MARK: Exposed API
    
    func register<T: UITableViewCell>(cellTypes: T.Type...) {
        cellTypes.forEach { (cellType) in
            tableView.register(cellType.nib, forCellReuseIdentifier: cellType.className)
        }
    }
    
    func refresh(with items: [TableViewSection]) {
        self.items = items
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
    
    func addItems(_ items: [TableViewSection]) {
        guard items.count == self.items.count else {
            fatalError("Number of sections changed. Please add support to Generic TableView")
        }
        
        let newIndexPaths: [IndexPath] = (0 ..< items.count).compactMap { (section) -> [IndexPath] in
            
            let initialItem = self.items[section].cellConfigurators.count
            self.items[section].cellConfigurators.append(contentsOf: items[section].cellConfigurators)
            
            return (initialItem ..< initialItem + items[section].cellConfigurators.count).compactMap { (item) -> IndexPath in
                return IndexPath(item: item, section: section)
            }
        }.reduce([], +)
        
        tableView.performBatchUpdates({
            tableView.insertRows(at: newIndexPaths, with: .fade)
        }, completion: nil)
    }
    
    func add(items: [CellConfiguratorProtocol], to section: Int) {
        guard section < self.items.count else {
            fatalError("Section index out of bounds")
        }
        
        let initialItemsCount = self.items[section].cellConfigurators.count
        
        let newIndexPaths: [IndexPath] = (initialItemsCount ..< initialItemsCount + items.count).map {
            IndexPath(row: $0, section: section)
        }
        
        self.items[section].cellConfigurators.append(contentsOf: items)
        
        tableView.performBatchUpdates({
            tableView.insertRows(at: newIndexPaths, with: .fade)
        }, completion: nil)
    }
    
    func refreshSection(_ section: Int, with items: [CellConfiguratorProtocol]) {
        guard section < self.items.count else {
            fatalError("Section index out of bounds")
        }
        
        self.items[section].cellConfigurators = items
        endRefreshing()
        tableView.reloadSections(IndexSet([section]), with: .fade)
    }
    
    func updateItems(with updateHandler: ([TableViewSection]) -> ([IndexPath])) {
        let indexPathsToUpdate = updateHandler(items)
        if !indexPathsToUpdate.isEmpty {
            tableView.reloadRows(at: indexPathsToUpdate, with: .none)
        }
    }
    
    func endRefreshing() {
        refreshControl.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
    }
    
    func startFiltering(with filter: ((CellConfiguratorProtocol) -> Bool)) {
        isFilteringEnabled = true
        filteredItems = items.map {
            let filteredConfigurators = $0.cellConfigurators.filter { (item) -> Bool in
                return filter(item)
            }
            return TableViewSection(header: $0.header, cellConfigurators: filteredConfigurators, footer: $0.footer)
        }
        tableView.reloadData()
    }
    
    func stopFiltering() {
        isFilteringEnabled = false
        filteredItems = []
        tableView.reloadData()
    }
}

extension TableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFilteringEnabled ? filteredItems.count : items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFilteringEnabled ? filteredItems[section].cellConfigurators.count : items[section].cellConfigurators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.item(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseID, for: indexPath)
        item.configure(cell: cell, at: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let _ = interSectionSpacing {
            let headerView = UIView()
            headerView.backgroundColor = .clear
            return headerView
        }
        
        guard let header = items[section].header else { return nil }
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.reuseID) else { return nil }
        header.configure(headerFooterView: view, at: section)
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let interSectionSpacing = interSectionSpacing {
            return section == 0 ? 0 : interSectionSpacing
        }
        guard let headerHeight = items[section].header?.height else { return 0 }
        return headerHeight
    }
    
}

extension TableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if autoDeselectsOnSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        delegate?.didSelectRow?(with: item(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let shouldSelectRow = delegate?.shouldSelectRow?(at: indexPath) else {
            return indexPath
        }
        return shouldSelectRow ? indexPath : nil
    }
}

