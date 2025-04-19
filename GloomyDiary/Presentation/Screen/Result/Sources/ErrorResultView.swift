//
//  ErrorResultView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/2/24.
//

import UIKit

final class ErrorResultView: UIView {
    
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
    
    let characterImageView = UIImageView()
    
    let informationLabel = NormalLabel().then {
        $0.text = "일시적인 오류가 발생했어요."
    }
    
    let subInformationLabel = NormalLabel().then {
        $0.text = """
        네트워크가 잘 연결되어 있는지 확인해보세요.
        잠시 기다렸다가 다시 시도해보세요.
        """
        $0.textColor = AppColor.Text.subHighlight.color
    }
    
    let backButton = HorizontalButton().then {
        $0.setTitle("뒤로가기", for: .normal)
        $0.setOriginBackgroundColor(with: AppColor.Component.subHorizontalButton.color)
    }
    
    let homeButton = HorizontalButton().then {
        $0.setTitle("홈으로", for: .normal)
    }
    
    
    // MARK: - Initialize
    
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
        backgroundColor = AppColor.Background.main.color
    }
    
    private func addSubviews() {
        addSubview(characterImageView)
        addSubview(informationLabel)
        addSubview(subInformationLabel)
        addSubview(backButton)
        addSubview(homeButton)
    }

    private func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.characterImageTopPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(Metric.characterImageSize)
            make.width.equalTo(Metric.characterImageSize)
        }
        
        informationLabel.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(Metric.NormalLabelTopPadding)
            make.centerX.equalToSuperview()
        }
        
        subInformationLabel.snp.makeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(Metric.subNormalLabelTopPadding)
            make.centerX.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(subInformationLabel.snp.bottom).offset(Metric.backButtonTopPadding)
            make.centerX.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(Metric.homeButtonTopPadding)
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(with character: CounselingCharacter) {
        characterImageView.image = AppImage.Character.counselor(character, .crying).image
    }
}

extension ErrorResultView {
    func hideAllComponents() {
        subviews.exclude(characterImageView).forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playAllComponentsFadeIn(duration: TimeInterval) async {
        hideAllComponents()
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: subviews.exclude(characterImageView).map {
                    Animation(view: $0,
                              animationCase: .fadeIn,
                              duration: duration) },
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAllComponentsFadeOut(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: subviews.map {
                    Animation(view: $0,
                              animationCase: .fadeOut,
                              duration: duration) },
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
