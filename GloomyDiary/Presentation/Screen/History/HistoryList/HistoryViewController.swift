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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        store.send(.refresh)
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
        
        for (index, sessionDTO) in store.counselingSessionDTOs.enumerated() {
            let counselingSessionConfiguration: TableViewCellConfigurable = CounselingSessionTableViewCellConfiguration(counselingSessionDTO: sessionDTO)
            configurables.append(counselingSessionConfiguration)
            
            if index < store.counselingSessionDTOs.count - 1 {
                let spacerConfiguration: TableViewCellConfigurable = SpacerTableViewCellConfiguration(spacing: spacing)
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
        self.navigationController?.pushViewController(HistoryDetailViewController(session: selectedConfiguration.counselingSessionDTO), animated: true)
    }
}
