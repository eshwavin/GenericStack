import UIKit

@objc public protocol CollectionViewDelegate: AnyObject {
    @objc optional func didSelectItem(_ item: CellConfiguratorProtocol, at indexPath: IndexPath)
    @objc optional func shouldSelectItem(at indexPath: IndexPath) -> Bool
    @objc optional func didPullToRefresh()
    @objc optional func shouldBeginPrefetching(in section: Int)
    @objc optional func shouldDeselectItem(at indexPath: IndexPath) -> Bool
    @objc optional func didDeselectItem(_ item: CellConfiguratorProtocol, at indexPath: IndexPath)
    @objc optional func didShowBottomRefreshControl()
    @objc optional var hasMoreData: Bool { get }
}

public protocol CollectionViewSizeProvider: AnyObject {
    func sizeForItem(_ item: CellConfiguratorProtocol, at indexPath: IndexPath, layout collectionViewLayout: UICollectionViewLayout) -> CGSize
}

final public class CollectionView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Queues
    
    private let removeQueue = DispatchQueue(label: "com.CollectionView.removeQueue")
    private let itemsQueue = DispatchQueue(label: "com.CollectionView.itemsQueue")
    
    // MARK: - CollectionView

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    // MARK: - Data
    
    private var items: [CollectionViewSection] = [] {
        didSet {
            endRefreshing()
            endBottomRefreshing()
        }
    }
    
    private var filteredItems: [CollectionViewSection] = [] {
        didSet {
            endRefreshing()
            endBottomRefreshing()
        }
    }
    
    private var relevantItems: [CollectionViewSection] {
        return isFilteringEnabled ? filteredItems : items
    }
    
    // MARK: - Filtering
    
    private var filter: ((CellConfiguratorProtocol) -> Bool)?
    
    private var isFilteringEnabled: Bool = false
    
    // MARK: - Refresh and Bottom Loader
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        return refreshControl
    }()
    
    
    private lazy var bottomRefreshControl: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .white
        activityIndicator.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: bottomRefreshControlHeight)
        return activityIndicator
    }()
    
    private let bottomRefreshControlHeight: CGFloat = 44
    
    // MARK: - Prefetching
    
    private(set) var isPrefetchingEnabled: Bool = false
    private var prefetchingSections: IndexSet = []
    private var prefetchingOffset: Int?
    
    private var contentOffsetRatio: CGPoint = .zero
    
    // MARK: - Settable Properties
    
    public weak var delegate: CollectionViewDelegate?
    public weak var sizeProvider: CollectionViewSizeProvider?
    
    public var supportsPullToRefresh: Bool = false {
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
    
    public var supportsBottomRefreshForInfiniteScroll = false
    
    public var allowsSelection: Bool = true {
        didSet {
            collectionView.allowsSelection = allowsSelection
        }
    }
    
    public var allowsMultipleSelection: Bool = false {
        didSet {
            collectionView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    public var isScrollEnabled: Bool {
        set {
            collectionView.isScrollEnabled = newValue
        }
        get {
            return collectionView.isScrollEnabled
        }
    }
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            collectionView.contentInset = contentInset
        }
    }
    
    public var contentOffset: CGPoint {
        set {
            collectionView.contentOffset = newValue
        }
        get {
            return collectionView.contentOffset
        }
    }
    
    public var collectionViewClipsToBounds: Bool = true {
        didSet {
            collectionView.clipsToBounds = clipsToBounds
        }
    }
    
    public var alwaysBounceHorizontal: Bool = false {
        didSet {
            collectionView.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
    }
    
    public var alwaysBounceVertical: Bool = false {
        didSet {
            collectionView.alwaysBounceVertical = alwaysBounceVertical
        }
    }
    
    public var remembersLastFocusedIndexPath: Bool = false {
        didSet {
            collectionView.remembersLastFocusedIndexPath = remembersLastFocusedIndexPath
        }
    }
    
    public var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none {
        didSet {
            collectionView.keyboardDismissMode = keyboardDismissMode
        }
    }
    
    public var indexPathsForSelectedItems: [IndexPath]? {
        return collectionView.indexPathsForSelectedItems
    }
    
    // MARK: - Setup
    
    public init(layout: UICollectionViewLayout, collectionViewDataSource: UICollectionViewDataSource? = nil, collectionViewDelegate: UICollectionViewDelegate? = nil) {
        super.init(frame: .zero)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = collectionViewDataSource == nil ? self : collectionViewDataSource
        collectionView.delegate = collectionViewDelegate == nil ? self : collectionViewDelegate
        layoutUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        addSubview(collectionView)
        collectionView.pinAllEdges()
        collectionView.layoutIfNeeded()
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 14, *) { }
        else {
            reloadData()
        }
    }
    
    // MARK: - Data Helpers
    
    private func relevantItem(at indexPath: IndexPath) -> CellConfiguratorProtocol {
        return relevantItems[indexPath.section].cellConfigurators[indexPath.row]
    }
    
    public func item(at indexPath: IndexPath) -> CellConfiguratorProtocol {
        return items[indexPath.section].cellConfigurators[indexPath.row]
    }
    
    public func getSection(_ section: Int) -> CollectionViewSection {
        return items[section]
    }
    
    // MARK: - Exposed API
    
    // MARK: - Changing DataSource and Delegate
    
    public func setDataSource(to dataSource: UICollectionViewDataSource) {
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    public func setCollectionViewDelegate(to delegate: UICollectionViewDelegate) {
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    // MARK: - Layout
    
    public func setLayout(to layout: UICollectionViewLayout, animated: Bool) {
        collectionView.setCollectionViewLayout(layout, animated: animated)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func invalidateLayout() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.collectionView.collectionViewLayout.invalidateLayout()
            self?.collectionView.layoutIfNeeded()
        }
        
    }
    
    // MARK: - Registering Views
    
    public func register<T: UICollectionViewCell>(cellTypes: T.Type...) {
        cellTypes.forEach { (cellType) in
            collectionView.register(cellType.nib, forCellWithReuseIdentifier: cellType.className)
        }
    }
    
    public func register<T: UICollectionViewCell>(cellType: T.Type, with nib: UINib) {
        collectionView.register(nib, forCellWithReuseIdentifier: cellType.className)
    }
    
    public func register<T: UICollectionViewCell>(cellClasses: T.Type...) {
        cellClasses.forEach { (cellClass) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.className)
        }
    }
    
    public func register<T: UICollectionReusableView>(reusableView: T.Type, for kind: String) {
        collectionView.register(reusableView.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reusableView.className)
    }
    
    public func register<T: UICollectionReusableView>(reusableViewClass: T.Type, for kind: String) {
        collectionView.register(reusableViewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reusableViewClass.className)
    }
    
    // MARK: - Data Info
    
    public func numberOfItems(in section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    public var numberOfSections: Int {
        return collectionView.numberOfSections
    }
    
    public func itemsInSection(_ section: Int) -> [CellConfiguratorProtocol] {
        itemsQueue.sync {
            return items[section].cellConfigurators
        }
    }
    
    // MARK: - Scrolling and selection

    public func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = false) {
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    public func scrollToLastItem(animated: Bool) {
        let lastSection = items.count - 1
        let lastItem = items[lastSection].cellConfigurators.count - 1
        let lastIndexPath = IndexPath(item: lastItem, section: lastSection)
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: animated)
    }
    
    @discardableResult public func selectItem(at indexPath: IndexPath, animated: Bool, scrollPosition: UICollectionView.ScrollPosition? = nil) -> CellConfiguratorProtocol? {
        
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
    
    public func deselectItem(at indexPath: IndexPath, animated: Bool) {
        collectionView.deselectItem(at: indexPath, animated: animated)
    }
    
    // MARK: - Data Loading
    
    public func reloadData(completion: (() -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            completion?()
        }
    }
    
    public func refresh(with items: [CollectionViewSection], completion: (() -> ())? = nil) {
        itemsQueue.sync {
            self.items = items
            if isFilteringEnabled {
                setFilteredItems()
            }
            reloadData(completion: completion)
        }
    }
    
    public func addItems(_ items: [CollectionViewSection]) {
        
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
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: newIndexPaths)
                    }, completion: nil)
                }
                
            }
        }
    }
    
    public func addSections(_ sections: [CollectionViewSection]) {
        
        itemsQueue.sync {
            
            if isFilteringEnabled {
                items.append(contentsOf: sections)
                setFilteredItems()
                reloadData()
            }
            else {
                let newSections: IndexSet = IndexSet(items.count..<(items.count + sections.count))
                
                let newIndexPaths: [IndexPath] = (items.count ..< items.count + sections.count).compactMap { (section) -> [IndexPath] in
                    
                    let rows = sections[section - items.count]
                    return (0 ..< rows.cellConfigurators.count).compactMap { (row) -> IndexPath in
                        return IndexPath(item: row, section: section)
                    }
                    
                }.reduce([], +)
                
                items.append(contentsOf: sections)
                
                DispatchQueue.main.async {
                    self.collectionView.performBatchUpdates({ [weak self] in
                        
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView.insertSections(newSections)
                        strongSelf.collectionView.insertItems(at: newIndexPaths)
                    }, completion: nil)
                }
            }
        }
                
    }

    public func add(items: [CellConfiguratorProtocol], to section: Int, at index: Int? = nil, completion: ((Bool) -> Void)? = nil) {
        
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
                
                DispatchQueue.main.async { [weak self] in
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
    
    public func reloadVisibleItems() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        
    }
    
    public func reloadSections(_ sections: IndexSet) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadSections(sections)
        }
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadItems(at: indexPaths)
        }
    }
    
    public func refreshSection(_ section: Int, with items: [CellConfiguratorProtocol], shouldReload: Bool = false) {
        
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.reloadSections(IndexSet([section]))
                }
                
            }
        }
        
    }
    
    public func updateItems(with updateHandler: ([CollectionViewSection]) -> ([IndexPath])) {
        
        itemsQueue.sync {
            let indexPathsToUpdate = updateHandler(items)
            if !indexPathsToUpdate.isEmpty {
                
                indexPathsToUpdate.forEach { (indexPath) in
                    let item = self.item(at: indexPath)
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if let cell = self.collectionView.cellForItem(at: indexPath) {
                            item.configure(cell: cell, at: indexPath)
                        }
                    }
                }
            }
        }
        
    }
    
    public func removeItem(at indexPath: IndexPath) {
        itemsQueue.sync {
            guard !isFilteringEnabled else { return }
            
            items[indexPath.section].cellConfigurators.remove(at: indexPath.item)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.deleteItems(at: [indexPath])
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    public func removeItems(matching predicate: @escaping (CellConfiguratorProtocol) -> Bool, in section: Int, completion: (() -> ())? = nil) {
        
        guard !isFilteringEnabled else { return }
        
        removeQueue.async {
            let semaphore = DispatchSemaphore(value: 0)
            
            DispatchQueue.main.async { [weak self] in
                
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
    
    public func setEmptyMessage(_ message: String, font: UIFont?) {
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
        messageLabel.pin(edges: .leading(spacing: 15), .trailing(spacing: -15))
    }
    
    public func removeEmptyMessage() {
        collectionView.backgroundView = nil
    }
    
    // MARK: - Filtering
    
    public func startFiltering(with filter: @escaping ((CellConfiguratorProtocol) -> Bool)) {
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
    
    public func stopFiltering() {
        isFilteringEnabled = false
        self.filter = nil
        filteredItems = []
        collectionView.reloadData()
    }
    
    // MARK: - Prefetching
    
    public func enablePrefetching(inSections sections: IndexSet, withOffset prefetchingOffset: Int) {
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
    
    // MARK: - Sorting
    
    public func sortItems(in section: Int, by sortingLogic: (CellConfiguratorProtocol, CellConfiguratorProtocol) throws -> Bool) {
        try? items[section].cellConfigurators.sort(by: sortingLogic)
        collectionView.reloadSections(IndexSet([section]))
    }
    
    public func sortItems(by sortingLogic: (CellConfiguratorProtocol, CellConfiguratorProtocol) throws -> Bool) {
        for section in 0 ..< items.count {
            sortItems(in: section, by: sortingLogic)
        }
    }
    
    // MARK: - Refresh Control and Bottom Refresh Control
    
    @objc private func didPullToRefresh() {
        delegate?.didPullToRefresh?()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) { [weak self] in
            self?.endRefreshing()
        }
    }
    
    public func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard supportsBottomRefreshForInfiniteScroll else { return }
        guard relevantItems.count > 0, bottomRefreshControl.superview == nil, delegate?.hasMoreData == true else { return }
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height / 2 {
            
            collectionView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: contentInset.bottom + bottomRefreshControlHeight, right: contentInset.right)
            
            scrollView.addSubview(bottomRefreshControl)
            scrollView.frameLayoutGuide.pin(edges: .leading(spacing: 0), .trailing(spacing: 0), .bottom(spacing: 5), to: bottomRefreshControl)
            
            bottomRefreshControl.startAnimating()
            
            delegate?.didShowBottomRefreshControl?()
        }
    }
    
    public func endBottomRefreshing() {
        guard supportsBottomRefreshForInfiniteScroll else { return }
        bottomRefreshControl.removeFromSuperview()
        collectionView.contentInset = contentInset
    }
    
    // MARK: - Misc
    
    public func perform(_ block: (UICollectionView) -> ()) {
        block(collectionView)
    }
    
}

// MARK: - UICollectionViewDataSource

extension CollectionView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        relevantItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relevantItems[section].cellConfigurators.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.relevantItem(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseID, for: indexPath)
        item.configure(cell: cell, at: indexPath)
        
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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

// MARK: - UICollectionViewDelegate
extension CollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem?(relevantItem(at: indexPath), at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return delegate?.shouldSelectItem?(at: indexPath) ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return delegate?.shouldDeselectItem?(at: indexPath) ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.didDeselectItem?(relevantItem(at: indexPath), at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isPrefetchingEnabled, !prefetchingSections.isEmpty, let prefetchingOffset = prefetchingOffset else { return }
        
        if prefetchingSections.contains(indexPath.section) {
            if indexPath.row + prefetchingOffset >= relevantItems[indexPath.section].cellConfigurators.count {
                delegate?.shouldBeginPrefetching?(in: indexPath.section)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.relevantItem(at: indexPath)
        
        return sizeProvider?.sizeForItem(item, at: indexPath, layout: collectionViewLayout) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
    
}
