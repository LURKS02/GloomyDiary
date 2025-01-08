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
        
        store.send(.refresh)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { @MainActor in
            guard let tabBarController = tabBarController as? CircularTabBarControllable else { return }
            await tabBarController.showCircularTabBar(duration: 0.2)
        }
        
        store.send(.refresh)
    }
}


// MARK: - bind

private extension HistoryViewController {
    func bind() {
        contentView.listView.tableView.dataSource = self
        contentView.listView.tableView.delegate = self
        
        observe { [weak self] in
            guard let self else { return }
            updateDataSource()
        }
    }
}


// MARK: - CollectionView

        
        
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let items = dataSource.snapshot().itemIdentifiers
        let item = items[indexPath.row]
        
        self.navigationController?.delegate = self
                                                  reducer: { HistoryDetail() })
        let historyDetailViewController = HistoryDetailViewController(store: store)
        self.navigationController?.pushViewController(historyDetailViewController, animated: true)
        Logger.send(type: .tapped, "히스토리 선택", parameters: ["인덱스": indexPath.row])
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
