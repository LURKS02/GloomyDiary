//
//  HistoryView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit

final class HistoryView: BaseView {
    
    // MARK: - Views
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 14
    }
    
    lazy var tableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(CounselingSessionTableViewCellConfiguration.cellType, forCellReuseIdentifier: CounselingSessionTableViewCellConfiguration.identifier)
        $0.register(SpacerTableViewCellConfiguration.cellType, forCellReuseIdentifier: SpacerTableViewCellConfiguration.identifier)
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        super.setup()
        
        self.backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().inset(17)
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(15)
        }
    }
}
