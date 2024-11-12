//
//  HistoryView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit

final class HistoryView: BaseView {
    
    // MARK: - Views
    
    var touchedPoint: CGPoint?
    
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
    
    private lazy var gradientBackgroundView = GradientView(colors: [.background(.mainPurple).withAlphaComponent(0.0), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        super.setup()
        
        self.backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(tableView)
        addSubview(gradientBackgroundView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
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

extension HistoryView {
    func hideAllComponents() {
        tableView.alpha = 0.0
    }
    
    @MainActor
    func playFadeInAllComponents(excpet cell: UITableViewCell) async {
        await withCheckedContinuation { continuation in
            let cellAnimations: [Animation] = tableView.visibleCells.filter { $0 !== cell }.map {
                Animation(view: $0, animationCase: .fadeIn, duration: 0.2)
            }
            
            AnimationGroup(animations: cellAnimations,
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() })).run()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents(except cell: UITableViewCell) async {
        await withCheckedContinuation { continuation in
            let cellAnimations: [Animation] = tableView.visibleCells.filter { $0 !== cell }.map {
                Animation(view: $0, animationCase: .fadeOut, duration: 0.3)
            }
            
            AnimationGroup(animations: cellAnimations + [Animation(view: gradientBackgroundView,
                                                                   animationCase: .fadeOut,
                                                                   duration: 0.3)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() })).run()
        }
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
