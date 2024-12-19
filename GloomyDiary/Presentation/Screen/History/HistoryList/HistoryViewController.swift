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

    private var configurables: [TableViewCellConfigurable] = [] {
        didSet {
            contentView.showContent = !configurables.isEmpty
        }
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


// MARK: - DataSource

private extension HistoryViewController {
    func updateDataSource() {
        if store.counselingSessionDTOs.isEmpty {
            configurables = []
            return
        }
        
        var configurables: [TableViewCellConfigurable] = []
        
        let spacing: CGFloat = 10.0
        
        configurables.append(SpacerTableViewCellConfiguration(spacing: spacing))
        
        for (index, sessionDTO) in store.counselingSessionDTOs.enumerated() {
            let counselingSessionConfiguration: TableViewCellConfigurable = CounselingSessionTableViewCellConfiguration(counselingSessionDTO: sessionDTO)
            configurables.append(counselingSessionConfiguration)
            
            if index < store.counselingSessionDTOs.count - 1 {
                let spacerConfiguration: TableViewCellConfigurable = SpacerTableViewCellConfiguration(spacing: spacing)
                configurables.append(spacerConfiguration)
            } else {
                let spacerConfiguration: TableViewCellConfigurable = SpacerTableViewCellConfiguration(spacing: 80)
                configurables.append(spacerConfiguration)
            }
        }
        
        self.configurables = configurables
    }
}


// MARK: - TableView

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        configurables.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configuration = configurables[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type(of: configuration).identifier) as? TableViewConfigurationBindable else { return UITableViewCell() }
        
        cell.bind(with: configuration)
        
        if let cell = cell as? CounselingSessionTableViewCell,
           let configurable = configuration as? CounselingSessionTableViewCellConfiguration
        {
            cell.imageCollectionView.rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    feedbackGenerator.impactOccurred()
                    self.navigationController?.delegate = self
                    let store: StoreOf<HistoryDetail> = Store(initialState: .init(session: configurable.counselingSessionDTO),
                                                              reducer: { HistoryDetail() })
                    let historyDetailViewController = HistoryDetailViewController(store: store)
                    self.navigationController?.pushViewController(historyDetailViewController, animated: true)
                    Logger.send(type: .tapped, "히스토리 선택", parameters: ["인덱스": indexPath.row])
                    
                })
                .disposed(by: cell.disposeBag)
            
        }
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedConfiguration = configurables[indexPath.row] as? CounselingSessionTableViewCellConfiguration else { return }
        self.navigationController?.delegate = self
        let store: StoreOf<HistoryDetail> = Store(initialState: .init(session: selectedConfiguration.counselingSessionDTO),
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
