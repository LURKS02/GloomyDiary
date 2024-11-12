//
//  StartCounselingView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import UIKit

final class StartCounselingView: BaseView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let moonTopPadding: CGFloat = 132
        static let firstIntroduceLabelTopPadding: CGFloat = 30
        static let secondIntroduceLabelTopPadding: CGFloat = 31
        static let thirdIntroduceLabelTopPadding: CGFloat = 22
        static let titleTextFieldTopPadding: CGFloat = 32
        static let finalIntroduceLabelTopPadding: CGFloat = 27
        static let nextButtonBottomPadding: CGFloat = 60
    }

    
    // MARK: - Views
    
    let moonImageView = ImageView().then {
        $0.setImage("moon")
        $0.setSize(43)
    }
    
    private let gradientView = GradientView(colors: [.background(.darkPurple), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    private lazy var firstIntroduceLabel = IntroduceLabel().then {
        $0.text = isFirstProcess ? "첫 번째 편지를 보내볼까요?" : "반가워요!"
    }
    
    private let secondIntroduceLabel = IntroduceLabel().then {
        $0.text = "가만히 눈을 감고\n" +
                  "오늘 하루를 떠올려보세요."
    }
    
    private let thirdIntroduceLabel = IntroduceLabel().then {
        $0.text = "준비되셨나요?"
    }
    
    let titleTextField = TextField()
    
    private let finalIntroduceLabel = IntroduceLabel().then {
        $0.text = "편지의 제목을 지어주세요."
    }
    
    let nextButton = HorizontalButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    
    // MARK: - Properties
    
    let isFirstProcess: Bool
    
    let moonMovingY: CGFloat = 35
    
    
    // MARK: - Initialize

    init(isFirstProcess: Bool) {
        self.isFirstProcess = isFirstProcess
        
        super.init(frame: .zero)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(moonImageView)
        addSubview(firstIntroduceLabel)
        addSubview(secondIntroduceLabel)
        addSubview(thirdIntroduceLabel)
        addSubview(titleTextField)
        addSubview(finalIntroduceLabel)
        addSubview(nextButton)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moonImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.moonTopPadding)
        }
        
        firstIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(moonImageView.snp.bottom).offset(Metric.firstIntroduceLabelTopPadding)
        }
        
        secondIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstIntroduceLabel.snp.bottom).offset(Metric.secondIntroduceLabelTopPadding)
        }
        
        thirdIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondIntroduceLabel.snp.bottom).offset(Metric.thirdIntroduceLabelTopPadding)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(thirdIntroduceLabel.snp.bottom).offset(Metric.titleTextFieldTopPadding)
            make.height.equalTo(60)
            make.width.equalTo(312)
        }
        
        finalIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleTextField.snp.bottom).offset(Metric.finalIntroduceLabelTopPadding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Metric.nextButtonBottomPadding)
        }
    }
}


// MARK: - Animations

extension StartCounselingView {
    func hideAllComponents() {
        subviews.filter { $0 != gradientView && $0 != moonImageView }
            .forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInFirstPart() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: moonImageView,
                                              animationCase: .moveUp(value: moonMovingY),
                                              duration: 1.5),
                                        .init(view: firstIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: secondIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 3.0)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInSecondPart() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: thirdIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: titleTextField,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: finalIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: nextButton,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: subviews.filter { $0 != gradientView }
                                               .map { Animation(view: $0,
                                                                animationCase: .fadeOut,
                                                                duration: 1.0)},
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
