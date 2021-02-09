//
//  CollectionView.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

@objc protocol CollectionViewDelegate: class {
    @objc optional func didSelectItem(_ item: CellConfiguratorProtocol, at indexPath: IndexPath)
    @objc optional func didPullToRefresh()
    @objc optional func shouldBeginPrefetching(in section: Int)
}

final class CollectionView: UIView {

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    private var items: [CollectionViewSection] = [] {
        didSet {
            endRefreshing()
        }
    }
    
    private var filteredItems: [CollectionViewSection] = [] {
        didSet {
            endRefreshing()
        }
    }
    
    private var isFilteringEnabled: Bool = false
    
    private lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    
    private var isPrefetchingEnabled: Bool = false
    private var prefetchingSections: IndexSet = []
    private var prefetchingOffset: Int?
    
    // MARK:- Settable Properties
    
    weak var delegate: CollectionViewDelegate?
    
    var supportsPullToRefresh: Bool = false {
        didSet {
            if supportsPullToRefresh {
                collectionView.refreshControl = refreshControl
                refreshControl.addTarget(delegate, action: #selector(delegate?.didPullToRefresh), for: .valueChanged)
            }
            else {
                collectionView.refreshControl = nil
                refreshControl.removeTarget(delegate, action: #selector(delegate?.didPullToRefresh), for: .valueChanged)
            }
        }
    }
    
    var allowsSelection: Bool = true {
        didSet {
            collectionView.allowsSelection = allowsSelection
        }
    }
    
    var isScrollEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            collectionView.contentInset = contentInset
        }
    }
    
    init(layout: UICollectionViewLayout,collectionViewDataSource: UICollectionViewDataSource? = nil, collectionViewDelegate: UICollectionViewDelegate? = nil) {
        super.init(frame: .zero)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = collectionViewDataSource == nil ? self : collectionViewDataSource
        collectionView.delegate = collectionViewDelegate == nil ? self : collectionViewDelegate
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        addSubview(collectionView)
        collectionView.pinAllEdges()
        collectionView.layoutIfNeeded()
    }
    
    // MARK: Helpers
    
    private func item(at indexPath: IndexPath) -> CellConfiguratorProtocol {
        return isFilteringEnabled ? filteredItems[indexPath.section].cellConfigurators[indexPath.row] : items[indexPath.section].cellConfigurators[indexPath.row]
    }
    
    // MARK: Exposed API
    
    func setDataSource(to dataSource: UICollectionViewDataSource) {
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    func setCollectionViewDelegate(to delegate: UICollectionViewDelegate) {
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    func setLayout(to layout: UICollectionViewLayout, animated: Bool) {
        collectionView.setCollectionViewLayout(layout, animated: animated)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func register<T: UICollectionViewCell>(cellTypes: T.Type...) {
        cellTypes.forEach { (cellType) in
            collectionView.register(cellType.nib, forCellWithReuseIdentifier: cellType.className)
        }
    }
    
    func register<T: UICollectionReusableView>(reusableView: T.Type, for kind: String) {
        collectionView.register(reusableView.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reusableView.className)
    }

    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = false) {
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func selectItem(at indexPath: IndexPath, animated: Bool, scrollPosition: UICollectionView.ScrollPosition? = nil) {
        
        if let scrollPosition = scrollPosition {
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
        else if let scrollDirection = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection,
                let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
            
            var scrollPosition: UICollectionView.ScrollPosition
            
            if scrollDirection == .horizontal {
                scrollPosition = .bottom
                let frame = layoutAttributes.frame
                
                if (frame.origin.x + frame.width) > collectionView.frame.width + collectionView.contentOffset.x {
                    scrollPosition = .right
                }
                else if frame.origin.x < collectionView.contentOffset.x {
                    scrollPosition = .left
                }
            }
            else {
                scrollPosition = .left
                let frame = layoutAttributes.frame
                
                if (frame.origin.y + frame.height) > collectionView.frame.height + collectionView.contentOffset.y {
                    scrollPosition = .bottom
                }
                else if frame.origin.y < collectionView.contentOffset.y {
                    scrollPosition = .top
                }
            }
            
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: scrollPosition)
        }
        
        
    }
    
    func refresh(with items: [CollectionViewSection]) {
        self.items = items
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        
    }
    
    func addItems(_ items: [CollectionViewSection]) {
        
        guard items.count == self.items.count else {
            fatalError("Number of sections changed. Please add support to Generic CollectionView")
        }
        
        let newIndexPaths: [IndexPath] = (0 ..< items.count).compactMap { (section) -> [IndexPath] in
            
            let initialItem = self.items[section].cellConfigurators.count
            self.items[section].cellConfigurators.append(contentsOf: items[section].cellConfigurators)
        
            return (initialItem ..< initialItem + items[section].cellConfigurators.count).compactMap { (item) -> IndexPath in
                return IndexPath(item: item, section: section)
            }
        }.reduce([], +)
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: newIndexPaths)
        }, completion: nil)

    }

    func add(items: [CellConfiguratorProtocol], to section: Int) {
        
        guard section < self.items.count else {
            fatalError("Section index out of bounds")
        }
        
        let initialItemsCount = self.items[section].cellConfigurators.count
        
        let newIndexPaths: [IndexPath] = (initialItemsCount ..< initialItemsCount + items.count).map {
            IndexPath(item: $0, section: section)
        }
        
        self.items[section].cellConfigurators.append(contentsOf: items)
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: newIndexPaths)
        }, completion: nil)
        
    }
    
    func refreshSection(_ section: Int, with items: [CellConfiguratorProtocol]) {
        guard section < self.items.count else {
            fatalError("Section index out of bounds")
        }
        
        self.items[section].cellConfigurators = items
        endRefreshing()
        collectionView.reloadSections(IndexSet([section]))
        
    }
    
    func updateItems(with updateHandler: ([CollectionViewSection]) -> ([IndexPath])) {
        let indexPathsToUpdate = updateHandler(items)
        if !indexPathsToUpdate.isEmpty {
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: indexPathsToUpdate)
            }
        }
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func startFiltering(with filter: ((CellConfiguratorProtocol) -> Bool)) {
        isFilteringEnabled = true
        filteredItems = items.map {
            let filteredConfigurators = $0.cellConfigurators.filter { (item) -> Bool in
                return filter(item)
            }
            return CollectionViewSection(header: $0.header, cellConfigurators: filteredConfigurators, footer: $0.footer)
        }
        collectionView.reloadData()
    }
    
    func stopFiltering() {
        isFilteringEnabled = false
        filteredItems = []
        collectionView.reloadData()
    }
    
    func perform(_ block: (UICollectionView) -> ()) {
        block(collectionView)
    }
    
    func enablePrefetching(inSections sections: IndexSet, withOffset prefetchingOffset: Int) {
        let itemsCount = items.count
        for section in sections {
            if itemsCount < section {
                fatalError("Section \(section) out of bounds of items with count: \(itemsCount)")
            }
        }
        
        isPrefetchingEnabled = true
        prefetchingSections = sections
        self.prefetchingOffset = prefetchingOffset
    }
    
}

// MARK:- UICollectionViewDataSource

extension CollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].cellConfigurators.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.item(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseID, for: indexPath)
        item.configure(cell: cell, at: indexPath)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = items[indexPath.section].header else { return UICollectionReusableView() }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: GlobalConstants.CollectionViewConstants.headerElementKind, withReuseIdentifier: header.reuseID, for: indexPath)
        header.configure(headerFooterView: headerView)
        return headerView
    }
}

// MARK:- UICollectionViewDelegate

extension CollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem?(item(at: indexPath), at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isPrefetchingEnabled, !prefetchingSections.isEmpty, let prefetchingOffset = prefetchingOffset else { return }
        
        if prefetchingSections.contains(indexPath.section) {
            if indexPath.row + prefetchingOffset >= items[indexPath.section].cellConfigurators.count {
                delegate?.shouldBeginPrefetching?(in: indexPath.section)
            }
        }
        
    }
}

