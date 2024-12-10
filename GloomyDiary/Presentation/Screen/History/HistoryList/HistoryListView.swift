//
//  HistoryListView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/13/24.
//

import UIKit

final class HistoryListView: UIView {
    
    // MARK: - Views
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 14
    }
    
    lazy var tableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.clipsToBounds = false
        $0.register(CounselingSessionTableViewCellConfiguration.cellType, forCellReuseIdentifier: CounselingSessionTableViewCellConfiguration.identifier)
        $0.register(SpacerTableViewCellConfiguration.cellType, forCellReuseIdentifier: SpacerTableViewCellConfiguration.identifier)
    }
    
    private let gradientBackgroundView = GradientView(colors: [.background(.mainPurple).withAlphaComponent(0.0), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        tableView.delaysContentTouches = false
    }
    
    private func addSubviews() {
        addSubview(tableView)
        addSubview(gradientBackgroundView)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().inset(17)
            make.bottom.equalToSuperview()
        }
        
        gradientBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(70)
        }
    }
}

extension HistoryListView {
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
