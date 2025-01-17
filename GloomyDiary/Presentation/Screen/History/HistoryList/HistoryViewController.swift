//
//  HistoryViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import ComposableArchitecture

final class HistoryViewController: BaseViewController<HistoryView> {
    
    typealias Section = HistorySection
    typealias Item = HistoryItem
    
    let store: StoreOf<History>
    
    private var sizeCache = Dictionary<DiffableSession, CGSize>()
    
    
    // MARK: - Properties

    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(
        collectionView: contentView.listView.collectionView
    ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CounselingSessionCollectionViewCell.identifier,
            for: indexPath
        ) as? CounselingSessionCollectionViewCell else { return nil }
        
        cell.saveIndex(indexPath.row)
        cell.configure(with: item.session)
        
        guard let self else { return nil }
        cell.indexTappedRelay
            .subscribe(onNext: { [weak self] index in
                self?.navigateToDetail(index: index)
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    // MARK: - Initialize
    
    init(store: StoreOf<History>) {
        self.store = store
        super.init(logID: "History")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        store.send(.refresh)
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
        
        redrawSnapshot(with: [], animated: false)
        
        observe { [weak self] in
            guard let self else { return }
            
            redrawSnapshot(with: store.Sessions.map { Item(session: $0) }, animated: false)
            updateContentView()
        }
    }
    
    func redrawSnapshot(with items: [Item], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func updateContentView() {
        contentView.showContent = dataSource.snapshot().itemIdentifiers.isEmpty ? false : true
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
            store.send(.loadNextPage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToDetail(index: indexPath.row)
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

extension HistoryViewController {
    private func navigateToDetail(index: Int) {
        let items = dataSource.snapshot().itemIdentifiers
        let item = items[index]
        
        self.navigationController?.delegate = self
        let store: StoreOf<HistoryDetail> = Store(initialState: .init(session: item.session),
                                                  reducer: { HistoryDetail() })
        let historyDetailViewController = HistoryDetailViewController(store: store)
        historyDetailViewController.deletionRelay.subscribe(onNext: { [weak self] id in
            guard let self else { return }
            var snapshot = dataSource.snapshot()
            let items = snapshot.itemIdentifiers
            let deleteItem = items[index]
            snapshot.deleteItems([deleteItem])
            
            UIView.performWithoutAnimation {
                self.dataSource.apply(snapshot, animatingDifferences: false)
                self.updateContentView()
                self.contentView.listView.collectionView.layoutIfNeeded()
            }
            })
        
        .disposed(by: rx.disposeBag)
        
        self.navigationController?.pushViewController(historyDetailViewController, animated: true)
        Logger.send(type: .tapped, "히스토리 선택", parameters: ["인덱스": index])
    }
}

extension HistoryViewController: CircularTabBarDelegate {
    func tabDidDisappear() {
        store.send(.unload)
    }
    
    func tabWillAppear() {
        store.send(.refresh)
    }
}


// MARK: - Transition Animation

extension HistoryViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        HistoryDetailTransition()
    }
}

extension HistoryViewController: ToTabSwitchable {
    func playTabAppearingAnimation() async {
        if contentView.showContent {
            await contentView.listView.playAppearingFromLeft()
        } else {
            await contentView.emptyView.playAppearingFromLeft()
        }
    }
}

extension HistoryViewController: FromTabSwitchable {
    func playTabDisappearingAnimation() async {
        if contentView.showContent {
            await contentView.listView.playDisappearingToRight()
        } else {
            await contentView.emptyView.playDisappearingToRight()
        }
    }
}
