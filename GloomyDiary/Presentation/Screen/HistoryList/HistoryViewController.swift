//
//  HistoryViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import ComposableArchitecture
import UIKit

final class HistoryViewController: BaseViewController<HistoryView> {
    typealias Section = HistorySection
    typealias Item = HistoryItem
    
    let store: StoreOf<History>
    
    private var sizeCache = Dictionary<DiffableSession, CGSize>()
    
    @Dependency(\.logger) var logger
    
    
    // MARK: - Properties

    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(
        collectionView: contentView.listView.collectionView
    ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CounselingSessionCollectionViewCell.identifier,
            for: indexPath
        ) as? CounselingSessionCollectionViewCell else { return nil }
        
        cell.configure(with: item.session)
        cell.touchSubject
            .sink { [weak self] in
                self?.navigationController?.delegate = self
                self?.store.send(.view(.didSelectCell(indexPath.row)))
            }
            .store(in: &cell.cancellableSet)
        
        return cell
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<History>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.delegate = self
        
        store.send(.view(.refresh))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { @MainActor in
            guard let tabBarController = tabBarController as? CircularTabBarControllable else { return }
            await tabBarController.showCircularTabBar(duration: 0.2)
        }
    }
}


// MARK: - bind

private extension HistoryViewController {
    func bind() {
        contentView.listView.collectionView.delegate = self
        
        observe { [weak self] in
            guard let self else { return }
            
            self.applySnapshot(with: store.items)
            self.updateVisibility(with: store.items)
        }
    }
}

// MARK: - Snapshot

private extension HistoryViewController {
    func applySnapshot(with items: [SessionItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        items.forEach { item in
            snapshot.appendItems([Item(session: item.session)])
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func updateVisibility(with items: [SessionItem]) {
        contentView.showContent = items.count == 0 ? false : true
    }
}


// MARK: - CollectionView

extension HistoryViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if store.isEndOfPage || store.isLoading { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        guard contentHeight > 0 else { return }
        
        if offsetY > contentHeight - frameHeight - 100 {
            store.send(.view(.loadNextPage))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.delegate = self
        store.send(.view(.didSelectCell(indexPath.row)))
    }
}

extension HistoryViewController: UICollectionViewDelegateFlowLayout {
    struct DiffableSession: Equatable, Hashable {
        let id: UUID
        let response: String
        let imageIDs: [UUID]
        
        init(_ session: Session) {
            self.id = session.id
            self.response = session.response
            self.imageIDs = session.imageIDs
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let items = dataSource.snapshot().itemIdentifiers
        let item = items[indexPath.row]
        let session = item.session
        
        let diffableSession = DiffableSession(session)
        
        if let size = sizeCache[diffableSession] {
            return size
        }
        
        else {
            let cell = CounselingSessionCollectionViewCell(frame: .zero)
            
            cell.configureWithDummy(with: session)
            
            let targetSize = CGSize(width: UIView.screenWidth - 17*2, height: UIView.layoutFittingCompressedSize.height)
            let size = cell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            sizeCache[diffableSession] = size
            
            return size
        }
    }
}


// MARK: - Tab Switch Delegate

extension HistoryViewController: CircularTabBarControllerDelegate {
    func tabDidDisappear() {
        contentView.listView.collectionView.setContentOffset(.zero, animated: false)
//        store.send(.unload)
    }
    
    func tabWillAppear() {
        store.send(.view(.refresh))
        
        self.logger.send(
            .tapped,
            "탭 바",
            ["현재 탭": "History"]
        )
    }
}


// MARK: - Transition

extension HistoryViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        return 
    }
}

extension HistoryViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        return
    }
}

extension HistoryViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.0,
            toDuration: 0.3,
            transitionContentType: .normalTransition
        )
    }
}

extension HistoryViewController: ToTabSwitchAnimatable {
    func playTabAppearingAnimation() async {
        if contentView.showContent {
            await contentView.listView.playAppearingFromLeft()
        } else {
            await contentView.emptyView.playAppearingFromLeft()
        }
    }
}

extension HistoryViewController: FromTabSwitchAnimatable {
    func playTabDisappearingAnimation() async {
        if contentView.showContent {
            await contentView.listView.playDisappearingToRight()
        } else {
            await contentView.emptyView.playDisappearingToRight()
        }
    }
}
