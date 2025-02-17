//
//  EmptyListView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/13/24.
//

import UIKit

final class EmptyListView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let ghostImageSize: CGFloat = 60
    }

    
    // MARK: - Views
    
    private let ghostImageView = UIImageView().then {
        $0.image = UIImage(named: "cryingGhost")
    }
    
    private let introduceLabel = NormalLabel().then {
        $0.text = """
        아직 아무 편지도
        보내지 않았어요.
        """
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
            make.height.equalTo(Metric.ghostImageSize)
            make.width.equalTo(Metric.ghostImageSize)
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ghostImageView.snp.bottom).offset(15)
        }
    }
}


// MARK: - Animations

extension EmptyListView {
    func hideAllComponents() {
        ghostImageView.alpha = 0.0
        introduceLabel.alpha = 0.0
    }
    
    @MainActor
    func playAppearingFromLeft() async {
        hideAllComponents()
        
        ghostImageView.transform = .identity.translatedBy(x: -10, y: 0)
        introduceLabel.transform = .identity.translatedBy(x: -10, y: 0)
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: ghostImageView,
                              animationCase: .fadeIn,
                              duration: 0.2),
                    Animation(view: ghostImageView,
                              animationCase: .transform(.identity),
                              duration: 0.2),
                    Animation(view: introduceLabel,
                              animationCase: .fadeIn,
                              duration: 0.2),
                    Animation(view: introduceLabel,
                              animationCase: .transform(.identity),
                              duration: 0.2)],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playDisappearingToRight() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: ghostImageView,
                                       animationCase: .fadeOut,
                                       duration: 0.2),
                             Animation(view: ghostImageView,
                                       animationCase: .transform(.identity.translatedBy(x: 10, y: 0)),
                                       duration: 0.2),
                             Animation(view: introduceLabel,
                                       animationCase: .fadeOut,
                                       duration: 0.2),
                             Animation(view: introduceLabel,
                                       animationCase: .transform(.identity.translatedBy(x: 10, y: 0)),
                                       duration: 0.2)],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
