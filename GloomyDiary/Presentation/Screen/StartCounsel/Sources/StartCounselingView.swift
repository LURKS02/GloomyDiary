//
//  StartCounselingView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import UIKit

final class StartCounselingView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let skyBadgeTopPadding: CGFloat = .deviceAdjustedHeight(97)
        static let firstNormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(80)
        static let secondNormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(31)
        static let thirdNormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(22)
        static let titleTextFieldTopPadding: CGFloat = .deviceAdjustedHeight(32)
        static let finalNormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(35)
        static let nextButtonTopPadding: CGFloat = .deviceAdjustedHeight(30)
        static let titleTextFieldHeight: CGFloat = 60
        static let titleTextFieldWidth: CGFloat = .deviceAdjustedWidth(312)
        static let skyBadgeImageSize: CGFloat = .deviceAdjustedHeight(43)
        static let warningLabelPadding: CGFloat = .deviceAdjustedHeight(5)
    }

    
    // MARK: - Views
    
    let containerView = UIView()
    
    let skyBadgeImageView = UIImageView().then {
        $0.image = AppImage.Component.skyBadge.image
        $0.alpha = 0.0
    }
    
    private let gradientView = GradientView(
        colors: [
            AppColor.Background.sub.color,
            AppColor.Background.main.color
        ],
        locations: [0.0, 0.5, 1.0]
    )
    
    private let firstNormalLabel = NormalLabel()
    
    private let secondNormalLabel = NormalLabel().then {
        $0.text = """
        가만히 눈을 감고
        오늘 하루를 떠올려보세요.
        """
    }
    
    private let thirdNormalLabel = NormalLabel().then {
        $0.text = "준비되셨나요?"
    }
    
    let titleTextField = RoundTextField()
    
    let warningLabel = UILabel().then {
        $0.text = "15자 이하로 작성해주세요."
        $0.textColor = AppColor.Text.warning.color
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .center
    }
    
    private let finalNormalLabel = NormalLabel().then {
        $0.text = "편지의 제목을 지어주세요."
    }
    
    let nextButton = NormalHorizontalButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    
    // MARK: - Initialize

    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
        
        hideAllComponents()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        backgroundColor = AppColor.Background.main.color
    }
    
    private func addSubviews() {
        addSubview(gradientView)
        addSubview(containerView)
        
        containerView.addSubview(skyBadgeImageView)
        containerView.addSubview(firstNormalLabel)
        containerView.addSubview(secondNormalLabel)
        containerView.addSubview(thirdNormalLabel)
        containerView.addSubview(titleTextField)
        containerView.addSubview(warningLabel)
        containerView.addSubview(finalNormalLabel)
        containerView.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        skyBadgeImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.skyBadgeTopPadding)
            make.height.equalTo(Metric.skyBadgeImageSize)
            make.width.equalTo(Metric.skyBadgeImageSize)
        }
        
        firstNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(skyBadgeImageView.snp.bottom).offset(Metric.firstNormalLabelTopPadding)
        }
        
        secondNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstNormalLabel.snp.bottom).offset(Metric.secondNormalLabelTopPadding)
        }
        
        thirdNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondNormalLabel.snp.bottom).offset(Metric.thirdNormalLabelTopPadding)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(thirdNormalLabel.snp.bottom).offset(Metric.titleTextFieldTopPadding)
            make.height.equalTo(Metric.titleTextFieldHeight)
            make.width.equalTo(Metric.titleTextFieldWidth)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(Metric.warningLabelPadding)
            make.leading.equalTo(titleTextField.snp.leading).offset(Metric.warningLabelPadding)
        }
        
        finalNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleTextField.snp.bottom).offset(Metric.finalNormalLabelTopPadding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(finalNormalLabel.snp.bottom).offset(Metric.nextButtonTopPadding)
        }
    }
    
    func configure(isFirstProcess: Bool) {
        firstNormalLabel.text = isFirstProcess ? "첫 번째 편지를 보내볼까요?" : "반가워요!"
    }
    
    func changeThemeIfNeeded() {
        backgroundColor = AppColor.Background.main.color
        skyBadgeImageView.image = AppImage.Component.skyBadge.image
        gradientView.updateColors([
            AppColor.Background.sub.color,
            AppColor.Background.main.color
        ])
        firstNormalLabel.changeThemeIfNeeded()
        secondNormalLabel.changeThemeIfNeeded()
        thirdNormalLabel.changeThemeIfNeeded()
        titleTextField.changeThemeIfNeeded()
        warningLabel.textColor = AppColor.Text.warning.color
        finalNormalLabel.changeThemeIfNeeded()
        nextButton.changeThemeIfNeeded()
    }
}


// MARK: - Animations

extension StartCounselingView {
    func hideAllComponents() {
        containerView.subviews.exclude(
            skyBadgeImageView,
            warningLabel
        ).forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playMovingSkyBadge(duration: TimeInterval) async {
        if skyBadgeImageView.alpha == 0.0 {
            await withCheckedContinuation { continuation in
                AnimationGroup(
                    animations: [
                        Animation(view: skyBadgeImageView,
                                  animationCase: .fadeIn,
                                  duration: duration)
                    ],
                    mode: .parallel,
                    loop: .once(completion: { continuation.resume() }))
                .run()
            }
        }
    }
    
    @MainActor
    func playFadeInFirstPart(duration: TimeInterval) async {
        skyBadgeImageView.transform = .identity.translatedBy(x: 0, y: .deviceAdjustedHeight(35))
        
        let percentages: [CGFloat] = [30, 20, 40, 10]
        let calculatedDurations = percentages.map { duration * $0 / 100 }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: skyBadgeImageView,
                              animationCase: .transform( .identity),
                              duration: calculatedDurations[0]),
                    Animation(view: firstNormalLabel,
                              animationCase: .fadeIn,
                              duration: calculatedDurations[1]),
                    Animation(view: secondNormalLabel,
                              animationCase: .fadeIn,
                              duration: calculatedDurations[2]),
                    Animation(view: thirdNormalLabel,
                              animationCase: .fadeIn,
                              duration: calculatedDurations[3])
                ],
                mode: .serial,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInSecondPart(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: titleTextField,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: finalNormalLabel,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: nextButton,
                              animationCase: .fadeIn,
                              duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents(duration: TimeInterval) async {
        let views = subviews.exclude(gradientView).map {
                Animation(view: $0,
                          animationCase: .fadeOut,
                          duration: duration)
            }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: views,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
