//
//  EmptyListView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/13/24.
//

import UIKit

final class EmptyListView: UIView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let ghostImageSize: CGFloat = 60
    }

    
    private let ghostImageView = ImageView().then {
        $0.setImage("cryingGhost")
        $0.setSize(Metric.ghostImageSize)
    }
    
    private let introduceLabel = IntroduceLabel().then {
        $0.text = "아직 아무 편지도\n" +
                  "보내지 않았어요."
    }
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func addSubviews() {
        addSubview(ghostImageView)
        addSubview(introduceLabel)
    }
    
    private func setupConstraints() {
        ghostImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ghostImageView.snp.bottom).offset(15)
        }
    }
}

extension EmptyListView {
    func hideAllComponents() {
        ghostImageView.alpha = 0.0
        introduceLabel.alpha = 0.0
    }
    
    @MainActor
    func playAppearingFromLeft() async {
        hideAllComponents()
        self.ghostImageView.transform = .identity.translatedBy(x: -10, y: 0)
        self.introduceLabel.transform = .identity.translatedBy(x: -10, y: 0)
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: self.ghostImageView,
                                              animationCase: .fadeIn,
                                              duration: 0.2),
                                        .init(view: self.ghostImageView,
                                              animationCase: .transform(transform: .identity),
                                              duration: 0.2),
                                        .init(view: introduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.2),
                                        .init(view: introduceLabel,
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
            AnimationGroup(animations: [.init(view: self.ghostImageView,
                                              animationCase: .fadeOut,
                                              duration: 0.2),
                                        .init(view: self.ghostImageView,
                                              animationCase: .transform(transform: .identity.translatedBy(x: 10, y: 0)), duration: 0.2),
                                        .init(view: self.introduceLabel, animationCase: .fadeOut, duration: 0.2),
                                        .init(view: self.introduceLabel,
                                              animationCase: .transform(transform: .identity.translatedBy(x: 10, y: 0)), duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
