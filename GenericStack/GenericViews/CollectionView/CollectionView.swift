import UIKit

@objc protocol CollectionViewDelegate: AnyObject {
    @objc optional func didSelectItem(_ item: CellConfiguratorProtocol, at indexPath: IndexPath)
    @objc optional func shouldSelectItem(at indexPath: IndexPath) -> Bool
    @objc optional func didPullToRefresh()
    @objc optional func shouldBeginPrefetching(in section: Int)
    @objc optional func shouldDeselectItem(at indexPath: IndexPath) -> Bool
    @objc optional func didDeselectItem(_ item: CellConfiguratorProtocol, at indexPath: IndexPath)
}

protocol CollectionViewSizeProvider: AnyObject {
    func sizeForItem(_ item: CellConfiguratorProtocol, at indexPath: IndexPath, layout collectionViewLayout: UICollectionViewLayout) -> CGSize
}

final class CollectionView: UIView {
    
    private let removeQueue = DispatchQueue(label: "com.CollectionView.removeQueue")
    private let itemsQueue = DispatchQueue(label: "com.CollectionView.itemsQueue")

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
    
    private var relevantItems: [CollectionViewSection] {
        return isFilteringEnabled ? filteredItems : items
    }
    
    private var filter: ((CellConfiguratorProtocol) -> Bool)?
    
    private var isFilteringEnabled: Bool = false
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        return refreshControl
    }()
    
    private(set) var isPrefetchingEnabled: Bool = false
    private var prefetchingSections: IndexSet = []
    private var prefetchingOffset: Int?
    
    private var contentOffsetRatio: CGPoint = .zero
    
    // MARK: - Settable Properties
    
    weak var delegate: CollectionViewDelegate?
    weak var sizeProvider: CollectionViewSizeProvider?
    
    var supportsPullToRefresh: Bool = false {
        didSet {
            if supportsPullToRefresh {
                collectionView.refreshControl = refreshControl
                refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
            }
            else {
                collectionView.refreshControl = nil
                refreshControl.removeTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
            }
        }
    }
    
    @objc private func didPullToRefresh() {
        delegate?.didPullToRefresh?()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) { [weak self] in
            self?.endRefreshing()
        }
    }
    
    var allowsSelection: Bool = true {
        didSet {
            collectionView.allowsSelection = allowsSelection
        }
    }
    
    var allowsMultipleSelection: Bool = false {
        didSet {
            collectionView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    var isScrollEnabled: Bool {
        set {
            collectionView.isScrollEnabled = newValue
        }
        get {
            return collectionView.isScrollEnabled
        }
    }
    
    var contentInset: UIEdgeInsets {
        set {
            collectionView.contentInset = newValue
        }
        get {
            return collectionView.contentInset
        }
    }
    
    var contentOffset: CGPoint {
        set {
            collectionView.contentOffset = newValue
        }
        get {
            return collectionView.contentOffset
        }
    }
    
    var collectionViewClipsToBounds: Bool = true {
        didSet {
            collectionView.clipsToBounds = clipsToBounds
        }
    }
    
    var alwaysBounceHorizontal: Bool = false {
        didSet {
            collectionView.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
    }
    
    var alwaysBounceVertical: Bool = false {
        didSet {
            collectionView.alwaysBounceVertical = alwaysBounceVertical
        }
    }
    
    var remembersLastFocusedIndexPath: Bool = false {
        didSet {
            collectionView.remembersLastFocusedIndexPath = remembersLastFocusedIndexPath
        }
    }
    
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none {
        didSet {
            collectionView.keyboardDismissMode = keyboardDismissMode
        }
    }
    
    var indexPathsForSelectedItems: [IndexPath]? {
        return collectionView.indexPathsForSelectedItems
    }
    
    init(layout: UICollectionViewLayout, collectionViewDataSource: UICollectionViewDataSource? = nil, collectionViewDelegate: UICollectionViewDelegate? = nil) {
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
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #unavailable(iOS 14) {
            reloadData()
        }
    }
    
    // MARK: - Helpers
    
    private func relevantItem(at indexPath: IndexPath) -> CellConfiguratorProtocol {
        return relevantItems[indexPath.section].cellConfigurators[indexPath.row]
    }
    
    func item(at indexPath: IndexPath) -> CellConfiguratorProtocol {
        return items[indexPath.section].cellConfigurators[indexPath.row]
    }
    
    func getSection(_ section: Int) -> CollectionViewSection {
        return items[section]
    }
    
    // MARK: - Exposed API
    
    // MARK:- Changing DataSource and Delegate
    
    func setDataSource(to dataSource: UICollectionViewDataSource) {
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    func setCollectionViewDelegate(to delegate: UICollectionViewDelegate) {
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    // MARK:- Layout
    
    func setLayout(to layout: UICollectionViewLayout, animated: Bool) {
        collectionView.setCollectionViewLayout(layout, animated: animated)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func invalidateLayout() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.collectionView.collectionViewLayout.invalidateLayout()
            self?.collectionView.layoutIfNeeded()
        }
        
    }
    
    // MARK:- Registering Views
    
    func register<T: UICollectionViewCell>(cellTypes: T.Type...) {
        cellTypes.forEach { (cellType) in
            collectionView.register(cellType.nib, forCellWithReuseIdentifier: cellType.className)
        }
    }
    
    func register<T: UICollectionViewCell>(cellType: T.Type, with nib: UINib) {
        collectionView.register(nib, forCellWithReuseIdentifier: cellType.className)
    }
    
    func register<T: UICollectionViewCell>(cellClasses: T.Type...) {
        cellClasses.forEach { (cellClass) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.className)
        }
        
    }
    
    func register<T: UICollectionReusableView>(reusableView: T.Type, for kind: String) {
        collectionView.register(reusableView.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reusableView.className)
    }
    
    // MARK:- Data Info
    
    func numberOfItems(in section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    func numberOfSections() -> Int {
        return collectionView.numberOfSections
    }
    
    func itemsInSection(_ section: Int) -> [CellConfiguratorProtocol] {
        itemsQueue.sync {
            return items[section].cellConfigurators
        }
    }
    
    // MARK:- Scrolling and selection

    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = false) {
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollToLastItem(animated: Bool) {
        let lastSection = items.count - 1
        let lastItem = items[lastSection].cellConfigurators.count - 1
        let lastIndexPath = IndexPath(item: lastItem, section: lastSection)
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: animated)
    }
    
    @discardableResult func selectItem(at indexPath: IndexPath, animated: Bool, scrollPosition: UICollectionView.ScrollPosition? = nil) -> CellConfiguratorProtocol? {
        
        if let scrollPosition = scrollPosition {
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
            return relevantItem(at: indexPath)
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
            return relevantItem(at: indexPath)
        }
        
        return nil
    }
    
    func deselectItem(at indexPath: IndexPath, animated: Bool) {
        collectionView.deselectItem(at: indexPath, animated: animated)
    }
    
    // MARK:- Data Loading
    
    func reloadData(completion: (() -> ())? = nil) {
        runOnMainThread { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            completion?()
        }
    }
    
    func refresh(with items: [CollectionViewSection], completion: (() -> ())? = nil) {
        itemsQueue.sync {
            self.items = items
            if isFilteringEnabled {
                setFilteredItems()
            }
            reloadData(completion: completion)
        }
    }
    
    func addItems(_ items: [CollectionViewSection]) {
        
        itemsQueue.sync {
            guard items.count == self.items.count else {
                fatalError("Number of sections changed. Please add support to Generic CollectionView")
            }
            
            if isFilteringEnabled {
                for section in (0 ..< items.count) {
                    self.items[section].cellConfigurators.append(contentsOf: items[section].cellConfigurators)
                }
                setFilteredItems()
                reloadData()
            }
            else {
                let newIndexPaths: [IndexPath] = (0 ..< items.count).compactMap { (section) -> [IndexPath] in
                    
                    let initialItem = self.items[section].cellConfigurators.count
                    self.items[section].cellConfigurators.append(contentsOf: items[section].cellConfigurators)
                
                    return (initialItem ..< initialItem + items[section].cellConfigurators.count).compactMap { (item) -> IndexPath in
                        return IndexPath(item: item, section: section)
                    }
                }.reduce([], +)
                
                runOnMainThread { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: newIndexPaths)
                    }, completion: nil)
                }
                
            }
        }
    }
    
    func addSections(_ sections: [CollectionViewSection]) {
        
        itemsQueue.sync {
            items.append(contentsOf: sections)
            
            if isFilteringEnabled {
                setFilteredItems()
                reloadData()
            }
            else {
                let newIndexPaths: [IndexPath] = (items.count ..< items.count + sections.count).compactMap { (section) -> [IndexPath] in
                    
                    let rows = sections[section]
                    return (0 ..< rows.cellConfigurators.count).compactMap { (row) -> IndexPath in
                        return IndexPath(item: row, section: section)
                    }
                    
                }.reduce([], +)
                
                runOnMainThread { [weak self] in
                    
                    guard let self = self else { return }
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: newIndexPaths)
                    }, completion: nil)
                }
            }
        }
                
    }

    func add(items: [CellConfiguratorProtocol], to section: Int, at index: Int? = nil, completion: ((Bool) -> Void)? = nil) {
        
        itemsQueue.sync {
            guard section < self.items.count else {
                fatalError("Section index out of bounds")
            }
            
            if let index = index {
                if index < 0 || index > self.items[section].cellConfigurators.count {
                    fatalError("Index out of bounds")
                }
            }
            
            let initialItemsCount: Int
            
            if let index = index {
                initialItemsCount = index
                self.items[section].cellConfigurators.insert(contentsOf: items, at: index)
            }
            else {
                initialItemsCount = self.items[section].cellConfigurators.count
                self.items[section].cellConfigurators.append(contentsOf: items)
            }
            
            let newIndexPaths: [IndexPath] = (initialItemsCount ..< initialItemsCount + items.count).map {
                IndexPath(item: $0, section: section)
            }
            
            if isFilteringEnabled {
                setFilteredItems()
                reloadData()
            }
            
            else {
                
                runOnMainThread { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: newIndexPaths)
                    }) { (success) in
                        completion?(success)
                    }
                }
            }
        }
        
    }
    
    func reloadVisibleItems() {
        runOnMainThread { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        
    }
    
    func reloadSections(_ sections: IndexSet) {
        runOnMainThread { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadSections(sections)
        }
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        runOnMainThread { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadItems(at: indexPaths)
        }
    }
    
    func refreshSection(_ section: Int, with items: [CellConfiguratorProtocol], shouldReload: Bool = false) {
        
        itemsQueue.sync {
            guard section < self.items.count else {
                fatalError("Section index out of bounds")
            }
            
            self.items[section].cellConfigurators = items
            
            if isFilteringEnabled {
                setFilteredItems()
                reloadData()
            }
            
            endRefreshing()
            if shouldReload {
                reloadData()
            }
            else {
                runOnMainThread { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.reloadSections(IndexSet([section]))
                }
                
            }
        }
        
    }
    
    func updateItems(with updateHandler: ([CollectionViewSection]) -> ([IndexPath])) {
        
        itemsQueue.sync {
            let indexPathsToUpdate = updateHandler(items)
            if !indexPathsToUpdate.isEmpty {
                
                indexPathsToUpdate.forEach { (indexPath) in
                    let item = self.item(at: indexPath)
                    
                    runOnMainThread { [weak self] in
                        guard let self = self else { return }
                        if let cell = self.collectionView.cellForItem(at: indexPath) {
                            item.configure(cell: cell, at: indexPath)
                        }
                    }
                }
            }
        }
        
    }
    
    func removeItem(at indexPath: IndexPath) {
        itemsQueue.sync {
            guard !isFilteringEnabled else { return }
            
            items[indexPath.section].cellConfigurators.remove(at: indexPath.item)
            
            runOnMainThread { [weak self] in
                guard let self = self else { return }
                self.collectionView.deleteItems(at: [indexPath])
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func removeItems(matching predicate: @escaping (CellConfiguratorProtocol) -> Bool, in section: Int, completion: (() -> ())? = nil) {
        
        guard !isFilteringEnabled else { return }
        
        removeQueue.async {
            let semaphore = DispatchSemaphore(value: 0)
            
            runOnMainThread { [weak self] in
                
                guard let self = self else {
                    semaphore.signal()
                    return
                }
                
                let indices: [Int] = self.items[section].cellConfigurators.indices(where: predicate)
                    
                self.items[section].cellConfigurators.remove(at: IndexSet(indices))
                    
                let indexPaths = indices.map {
                    IndexPath(item: $0, section: section)
                }
                    
                self.collectionView.deleteItems(at: indexPaths)
                
                
                completion?()
                semaphore.signal()
                
            }
            semaphore.wait()
        }
        
    }
    
    func setEmptyMessage(_ message: String, font: UIFont?) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.font = font
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        view.addSubview(messageLabel)
        collectionView.backgroundView = view
        messageLabel.centerX()
        messageLabel.centerY()
        messageLabel.pin(edges: .leading(padding: 15), .trailing(padding: -15))
    }
    
    func removeEmptyMessage() {
        collectionView.backgroundView = nil
    }
    
    // MARK:- Filtering
    
    func startFiltering(with filter: @escaping ((CellConfiguratorProtocol) -> Bool)) {
        isFilteringEnabled = true
        self.filter = filter
        setFilteredItems()
        collectionView.reloadData()
    }
    
    private func setFilteredItems() {
        guard isFilteringEnabled else { return }
        guard let filter = self.filter else {
            isFilteringEnabled = false
            return
        }
        
        filteredItems = items.map {
            let filteredConfigurators = $0.cellConfigurators.filter { (item) -> Bool in
                return filter(item)
            }
            return CollectionViewSection(header: $0.header, cellConfigurators: filteredConfigurators, footer: $0.footer)
        }
        
        guard isPrefetchingEnabled, let prefetchingOffset = prefetchingOffset else { return }
        
        for (index, filteredItem) in filteredItems.enumerated() {
            if prefetchingSections.contains(index) && filteredItem.cellConfigurators.count < prefetchingOffset {
                print("PF: Begin \(index)")
                delegate?.shouldBeginPrefetching?(in: index)
            }
        }
        
    }
    
    func stopFiltering() {
        isFilteringEnabled = false
        self.filter = nil
        filteredItems = []
        collectionView.reloadData()
    }
    
    // MARK:- Prefetching
    
    func enablePrefetching(inSections sections: IndexSet, withOffset prefetchingOffset: Int) {
        let itemsCount = relevantItems.count
        for section in sections {
            if itemsCount < section {
                fatalError("Section \(section) out of bounds of items with count: \(itemsCount)")
            }
        }
        
        isPrefetchingEnabled = true
        prefetchingSections = sections
        self.prefetchingOffset = prefetchingOffset
    }
    
    // MARK:- Sorting
    
    func sortItems(in section: Int, by sortingLogic: (CellConfiguratorProtocol, CellConfiguratorProtocol) throws -> Bool) {
        try? items[section].cellConfigurators.sort(by: sortingLogic)
        collectionView.reloadSections(IndexSet([section]))
    }
    
    func sortItems(by sortingLogic: (CellConfiguratorProtocol, CellConfiguratorProtocol) throws -> Bool) {
        for section in 0 ..< items.count {
            sortItems(in: section, by: sortingLogic)
        }
    }
    
    // MARK: Misc
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func perform(_ block: (UICollectionView) -> ()) {
        block(collectionView)
    }
    
}

// MARK:- UICollectionViewDataSource

extension CollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        relevantItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relevantItems[section].cellConfigurators.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.relevantItem(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseID, for: indexPath)
        item.configure(cell: cell, at: indexPath)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = relevantItems[indexPath.section].header else { return UICollectionReusableView() }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: header.reuseID, for: indexPath)
            header.configure(headerFooterView: headerView)
            return headerView
        }
        else if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = relevantItems[indexPath.section].footer else { return UICollectionReusableView() }
            
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footer.reuseID, for: indexPath)
            footer.configure(headerFooterView: footerView)
            return footerView
        }
        
        return UICollectionReusableView()
        
    }
}

// MARK:- UICollectionViewDelegate

extension CollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem?(relevantItem(at: indexPath), at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return delegate?.shouldSelectItem?(at: indexPath) ?? true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return delegate?.shouldDeselectItem?(at: indexPath) ?? true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.didDeselectItem?(relevantItem(at: indexPath), at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isPrefetchingEnabled, !prefetchingSections.isEmpty, let prefetchingOffset = prefetchingOffset else { return }
        
        if prefetchingSections.contains(indexPath.section) {
            if indexPath.row + prefetchingOffset >= relevantItems[indexPath.section].cellConfigurators.count {
                delegate?.shouldBeginPrefetching?(in: indexPath.section)
            }
        }
    }
}

extension CollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.relevantItem(at: indexPath)
        
        return sizeProvider?.sizeForItem(item, at: indexPath, layout: collectionViewLayout) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
    
}
