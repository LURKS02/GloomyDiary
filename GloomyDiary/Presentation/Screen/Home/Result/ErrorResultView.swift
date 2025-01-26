//
//  ErrorResultView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/2/24.
//

import UIKit

final class ErrorResultView: BaseView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let characterImageSize: CGFloat = .deviceAdjustedHeight(87)
        static let characterImageTopPadding: CGFloat = .deviceAdjustedHeight(100)
        static let NormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(20)
        static let subNormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(20)
        static let backButtonTopPadding: CGFloat = .deviceAdjustedHeight(30)
        static let homeButtonTopPadding: CGFloat = .deviceAdjustedHeight(10)
    }

    
    // MARK: - Views
    
    let characterImageView = ImageView().then {
        $0.setSize(Metric.characterImageSize)
    }
    
    let introduceLabel = IntroduceLabel().then {
        $0.text = "일시적인 오류가 발생했어요."
    }
    
    let subIntroduceLabel = IntroduceLabel().then {
        $0.text = """
        네트워크가 잘 연결되어 있는지 확인해보세요.
        잠시 기다렸다가 다시 시도해보세요.
        """
        $0.textColor = .text(.subHighlight)
    }
    
    let backButton = HorizontalButton().then {
        $0.setTitle("뒤로가기", for: .normal)
        $0.setOriginBackgroundColor(with: .component(.blackPurple))
    }
    
    let homeButton = HorizontalButton().then {
        $0.setTitle("홈으로", for: .normal)
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(characterImageView)
        addSubview(introduceLabel)
        addSubview(subIntroduceLabel)
        addSubview(backButton)
        addSubview(homeButton)
    }

    override func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.characterImageTopPadding)
            make.centerX.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(Metric.introduceLabelTopPadding)
            make.centerX.equalToSuperview()
        }
        
        subIntroduceLabel.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp.bottom).offset(Metric.subIntroduceLabelTopPadding)
            make.centerX.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(subIntroduceLabel.snp.bottom).offset(Metric.backButtonTopPadding)
            make.centerX.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(Metric.homeButtonTopPadding)
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(with character: CounselingCharacter) {
        characterImageView.setImage(character.cryingImageName)
    }
}

extension ErrorResultView {
    func hideAllComponents() {
        subviews.filter { $0 != characterImageView }.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playAllComponentsFadeIn() async {
        hideAllComponents()
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: subviews.filter { $0 != characterImageView }.map { Animation(view: $0,
                                                                                                    animationCase: .fadeIn,
                                                                                                    duration: 0.5) },
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAllComponentsFadeOut() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: subviews.map { Animation(view: $0,
                                                                animationCase: .fadeOut,
                                                                duration: 0.5) },
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
