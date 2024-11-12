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
    
    private var initialized: Bool = false
    
    
    // MARK: - Properties

    private var configurables: [TableViewCellConfigurable] = [] {
        didSet {
            self.contentView.tableView.reloadData()
        }
    }
    
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
        
        store.send(.refresh)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { @MainActor in
            guard let tabBarController = tabBarController as? CircularTabBarControllable else { return }
            await tabBarController.showCircularTabBar(duration: 0.2)
        }
        
        if !initialized {
            store.send(.refresh)
            initialized = true
        }
    }
}


// MARK: - bind

private extension HistoryViewController {
    func bind() {
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        
        observe { [weak self] in
            guard let self else { return }
            updateDataSource()
        }
    }
}


// MARK: - DataSource

private extension HistoryViewController {
    func updateDataSource() {
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
                let spacerConfiguration: TableViewCellConfigurable = SpacerTableViewCellConfiguration(spacing: 50)
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
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedConfiguration = configurables[indexPath.row] as? CounselingSessionTableViewCellConfiguration else { return }
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(HistoryDetailViewController(session: selectedConfiguration.counselingSessionDTO), animated: true)
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
        await contentView.playAppearingFromLeft()
    }
}

extension HistoryViewController: FromTabSwitchable {
    func playTabDisappearingAnimation() async {
        await contentView.playDisappearingToRight()
    }
}
