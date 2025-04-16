//
//  ValidResultView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/2/24.
//

import UIKit

final class ValidResultView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let characterImageSize: CGFloat = .deviceAdjustedHeight(87)
        static let characterImageTopPadding: CGFloat = .deviceAdjustedHeight(71)
        static let letterTopPadding: CGFloat = .deviceAdjustedHeight(14)
        static let letterHorizontalPadding: CGFloat = .deviceAdjustedWidth(17)
        static let letterBottomPadding: CGFloat = .deviceAdjustedHeight(218)
        static let shareButtonTopPadding: CGFloat = .deviceAdjustedHeight(25)
        static let homeButtonTopPadding: CGFloat = .deviceAdjustedHeight(15)
    }

    
    // MARK: - Views
    
    let characterImageView = UIImageView()
    
    let resultLetterView = ResultLetterView()
    
    let shareButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("공유하기", for: .normal)
        $0.setOriginBackgroundColor(with: AppColor.Component.blackPurple.color)
    }
    
    let homeButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("홈으로", for: .normal)
    }
    
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    private func setup() {
        backgroundColor = AppColor.Background.mainPurple.color
    }
    
    private func addSubviews() {
        addSubview(characterImageView)
        addSubview(resultLetterView)
        addSubview(shareButton)
        addSubview(homeButton)
    }
    
    private func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.characterImageTopPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(Metric.characterImageSize)
            make.width.equalTo(Metric.characterImageSize)
        }
        
        resultLetterView.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(Metric.letterTopPadding)
            make.leading.equalToSuperview().offset(Metric.letterHorizontalPadding)
            make.trailing.equalToSuperview().offset(-Metric.letterHorizontalPadding)
            make.bottom.equalToSuperview().offset(-Metric.letterBottomPadding)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(resultLetterView.snp.bottom).offset(Metric.shareButtonTopPadding)
            make.centerX.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(Metric.homeButtonTopPadding)
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(with character: CounselingCharacter) {
        characterImageView.image = UIImage(named: character.imageName)
    }
}

// MARK: - Animations

extension ValidResultView {
    func hideAllComponents() {
        subviews.filter { $0 != characterImageView }.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playAllComponentsFadeIn(duration: TimeInterval) async {
        hideAllComponents()
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: resultLetterView,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: homeButton,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: shareButton,
                              animationCase: .fadeIn,
                              duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAllComponentsFadeOut(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: resultLetterView,
                              animationCase: .fadeOut,
                              duration: duration),
                    Animation(view: homeButton,
                              animationCase: .fadeOut,
                              duration: duration),
                    Animation(view: characterImageView,
                              animationCase: .fadeOut,
                              duration: duration),
                    Animation(view: shareButton,
                              animationCase: .fadeOut,
                              duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
