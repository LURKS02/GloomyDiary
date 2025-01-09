//
//  HistoryViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import ComposableArchitecture

final class HistoryViewController: BaseViewController<HistoryView> {
    
    let store: StoreOf<History>
    
    
    // MARK: - Properties

    private lazy var dataSource = UICollectionViewDiffableDataSource<HistorySection, HistoryItem>(collectionView: contentView.listView.collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CounselingSessionCollectionViewCell.identifier, for: indexPath) as? CounselingSessionCollectionViewCell else { return nil }
        cell.configure(with: item.session)
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
            
            redrawSnapshot(with: store.counselingSessionDTOs.map { HistoryItem(session: $0) }, animated: false)
            contentView.showContent = dataSource.snapshot().itemIdentifiers.isEmpty ? false : true
        }
    }
    
    func redrawSnapshot(with items: [HistoryItem], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<HistorySection, HistoryItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
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
        let items = dataSource.snapshot().itemIdentifiers
        let item = items[indexPath.row]
        
        self.navigationController?.delegate = self
        let store: StoreOf<HistoryDetail> = Store(initialState: .init(session: item.session),
                                                  reducer: { HistoryDetail() })
        let historyDetailViewController = HistoryDetailViewController(store: store)
        historyDetailViewController.deletionRelay.subscribe(onNext: { [weak self] id in
            guard let self else { return }
            var snapshot = dataSource.snapshot()
            let items = snapshot.itemIdentifiers
            let deleteItem = items[indexPath.row]
            snapshot.deleteItems([deleteItem])
            
            dataSource.apply(snapshot, animatingDifferences: true)
            })
        
        .disposed(by: rx.disposeBag)
        
        self.navigationController?.pushViewController(historyDetailViewController, animated: true)
        Logger.send(type: .tapped, "히스토리 선택", parameters: ["인덱스": indexPath.row])
        
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
