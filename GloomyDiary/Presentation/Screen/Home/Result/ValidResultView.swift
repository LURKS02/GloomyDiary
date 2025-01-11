//
//  ValidResultView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/2/24.
//

import UIKit

final class ValidResultView: BaseView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let characterImageSize: CGFloat = .verticalValue(87)
        static let characterImageTopPadding: CGFloat = .verticalValue(71)
        static let letterTopPadding: CGFloat = .verticalValue(14)
        static let letterHorizontalPadding: CGFloat = .horizontalValue(17)
        static let letterBottomPadding: CGFloat = .verticalValue(218)
        static let shareButtonTopPadding: CGFloat = .verticalValue(25)
        static let homeButtonTopPadding: CGFloat = .verticalValue(15)
    }

    
    // MARK: - Views
    
    let characterImageView: ImageView = ImageView().then {
        $0.setSize(Metric.characterImageSize)
    }
    
    let resultLetterView = ResultLetterView()
    
    let shareButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("공유하기", for: .normal)
        $0.setOriginBackgroundColor(with: .component(.blackPurple))
    }
    
    let homeButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("홈으로", for: .normal)
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(characterImageView)
        addSubview(resultLetterView)
        addSubview(shareButton)
        addSubview(homeButton)
    }
    
    override func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.characterImageTopPadding)
            make.centerX.equalToSuperview()
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
    
    func configure(with character: CharacterDTO) {
        characterImageView.setImage(character.imageName)
    }
}

// MARK: - Animations

extension ValidResultView {
    func hideAllComponents() {
        subviews.filter { $0 != characterImageView }.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playAllComponentsFadeIn() async {
        hideAllComponents()
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: resultLetterView,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: homeButton,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: shareButton,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAllComponentsFadeOut() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: resultLetterView,
                                              animationCase: .fadeOut,
                                              duration: 0.5),
                                        .init(view: homeButton,
                                              animationCase: .fadeOut,
                                              duration: 0.5),
                                        .init(view: characterImageView,
                                              animationCase: .fadeOut,
                                              duration: 0.5),
                                        .init(view: shareButton,
                                              animationCase: .fadeOut,
                                              duration: 0.5)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
