//
//  StartCounselingView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import UIKit

final class StartCounselingView: BaseView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let moonTopPadding: CGFloat = .verticalValue(97)
        static let firstIntroduceLabelTopPadding: CGFloat = .verticalValue(80)
        static let secondIntroduceLabelTopPadding: CGFloat = .verticalValue(31)
        static let thirdIntroduceLabelTopPadding: CGFloat = .verticalValue(22)
        static let titleTextFieldTopPadding: CGFloat = .verticalValue(32)
        static let finalIntroduceLabelTopPadding: CGFloat = .verticalValue(35)
        static let nextButtonTopPadding: CGFloat = .verticalValue(30)
        static let titleTextFieldHeight: CGFloat = 60
        static let titleTextFieldWidth: CGFloat = .horizontalValue(312)
        static let moonImageSize: CGFloat = .verticalValue(43)
        static let warningLabelPadding: CGFloat = .verticalValue(5)
    }

    
    // MARK: - Views
    
    let containerView = UIView()
    
    let moonImageView = ImageView().then {
        $0.setImage("moon")
        $0.setSize(Metric.moonImageSize)
    }
    
    private let gradientView = GradientView(colors: [.background(.darkPurple), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    private lazy var firstIntroduceLabel = IntroduceLabel().then {
        $0.text = isFirstProcess ? "첫 번째 편지를 보내볼까요?" : "반가워요!"
    }
    
    private let secondIntroduceLabel = IntroduceLabel().then {
        $0.text = """
        가만히 눈을 감고
        오늘 하루를 떠올려보세요.
        """
    }
    
    private let thirdIntroduceLabel = IntroduceLabel().then {
        $0.text = "준비되셨나요?"
    }
    
    let titleTextField = TextField()
    
    let warningLabel = UILabel().then {
        $0.text = "15자 이하로 작성해주세요."
        $0.textColor = .text(.warning)
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .center
    }
    
    private let finalIntroduceLabel = IntroduceLabel().then {
        $0.text = "편지의 제목을 지어주세요."
    }
    
    let nextButton = HorizontalButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    
    // MARK: - Properties
    
    let isFirstProcess: Bool
    
    
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
        addSubview(containerView)
        
        containerView.addSubview(moonImageView)
        containerView.addSubview(firstIntroduceLabel)
        containerView.addSubview(secondIntroduceLabel)
        containerView.addSubview(thirdIntroduceLabel)
        containerView.addSubview(titleTextField)
        containerView.addSubview(warningLabel)
        containerView.addSubview(finalIntroduceLabel)
        containerView.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
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
            make.height.equalTo(Metric.titleTextFieldHeight)
            make.width.equalTo(Metric.titleTextFieldWidth)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(Metric.warningLabelPadding)
            make.leading.equalTo(titleTextField.snp.leading).offset(Metric.warningLabelPadding)
        }
        
        finalIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleTextField.snp.bottom).offset(Metric.finalIntroduceLabelTopPadding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(finalIntroduceLabel.snp.bottom).offset(Metric.nextButtonTopPadding)
        }
    }
}


// MARK: - Animations

extension StartCounselingView {
    func hideAllComponents() {
        firstIntroduceLabel.alpha = 0.0
        secondIntroduceLabel.alpha = 0.0
        thirdIntroduceLabel.alpha = 0.0
        titleTextField.alpha = 0.0
        finalIntroduceLabel.alpha = 0.0
        nextButton.alpha = 0.0
    }
    
    @MainActor
    func playFadeInFirstPart() async {
        moonImageView.transform = .identity.translatedBy(x: 0, y: .verticalValue(35))
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: moonImageView,
                                              animationCase: .transform(transform: .identity),
                                              duration: 1.0),
                                        .init(view: firstIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: secondIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.5),
                                        .init(view: thirdIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInSecondPart() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: titleTextField,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: finalIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: nextButton,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .parallel,
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
                                                                duration: 0.5)},
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
