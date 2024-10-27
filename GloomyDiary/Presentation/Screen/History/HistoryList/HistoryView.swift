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

extension HistoryView {
    func hideAllComponents() {
        tableView.alpha = 0.0
    }
    
    @MainActor
    func playAppearingFromLeft() async {
        hideAllComponents()
        self.tableView.transform = .identity.translatedBy(x: -10, y: 0)
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: self.tableView,
                                              animationCase: .fadeIn,
                                              duration: 0.2),
                                        .init(view: self.tableView,
                                              animationCase: .transform(transform: .identity),
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playDisappearingToRight() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: self.tableView,
                                              animationCase: .fadeOut,
                                              duration: 0.2),
                                        .init(view: self.tableView,
                                              animationCase: .transform(transform: .identity.translatedBy(x: 10, y: 0)),
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
