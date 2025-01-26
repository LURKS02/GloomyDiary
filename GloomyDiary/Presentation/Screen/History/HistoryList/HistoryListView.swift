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
        $0.sectionInset = .init(top: 0, left: 0, bottom: .deviceAdjustedHeight(70), right: 0)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(CounselingSessionCollectionViewCell.self, forCellWithReuseIdentifier: CounselingSessionCollectionViewCell.identifier)
    }
    
    private let gradientBackgroundView = GradientView(colors: [.background(.mainPurple).withAlphaComponent(0.0), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        collectionView.delaysContentTouches = false
    }
    
    private func addSubviews() {
        addSubview(collectionView)
        addSubview(gradientBackgroundView)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
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


// MARK: - Animations

extension HistoryListView {
    func hideAllComponents() {
        collectionView.alpha = 0.0
    }
    
    @MainActor
    func playAppearingFromLeft() async {
        hideAllComponents()
        self.collectionView.transform = .identity.translatedBy(x: -10, y: 0)
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: self.collectionView,
                                       animationCase: .fadeIn,
                                       duration: 0.2),
                             Animation(view: self.collectionView,
                                       animationCase: .transform( .identity),
                                       duration: 0.2)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playDisappearingToRight() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: self.collectionView,
                                       animationCase: .fadeOut,
                                       duration: 0.2),
                             Animation(view: self.collectionView,
                                       animationCase: .transform( .identity.translatedBy(x: 10, y: 0)),
                                       duration: 0.2)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
