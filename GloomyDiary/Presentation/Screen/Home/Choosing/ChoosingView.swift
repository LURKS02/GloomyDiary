//
//  ChoosingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class ChoosingView: BaseView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let secondIntroduceLabelSuperViewPadding: CGFloat = 240
        static let firstSecondIntroduceLabelPadding: CGFloat = 31
        static let characterStackViewTopPadding: CGFloat = 30
        static let characterStackViewBottomPadding: CGFloat = 30
        static let stackViewSpacing: CGFloat = 11
        static let counselButtonBottomPadding: CGFloat = 60
        
        static let moonImageSize: CGFloat = 43
        static let moonTopPadding: CGFloat = 132
    }
    
    
    // MARK: - Views
    
    let moonImageView: ImageView = ImageView().then {
        $0.setImage("moon")
        $0.setSize(43)
    }
    
    let gradientView: GradientView = GradientView(colors: [.background(.darkPurple),
                                                           .background(.mainPurple),
                                                           .background(.mainPurple)])
    
    lazy var firstIntroduceLabel: IntroduceLabel = IntroduceLabel().then {
        $0.text = isFirstProcess ? "첫 번째 상담을 진행해볼까요?" : "반가워요!"
    }
    
    lazy var secondIntroduceLabel: IntroduceLabel = IntroduceLabel().then {
        $0.text = isFirstProcess ? "\"울다\"에는\n" +
                                   "여러분들의 이야기를 들어줄\n" +
                                   "세 마리의 상담사가 있어요." 
                                   :
                                   "오늘은 어떤 일이 있었나요?\n" +
                                   "당신의 이야기를 들려주세요."
    }
    
    let characterButtonStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = Metric.stackViewSpacing
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    let characterIntroduceLabel: IntroduceLabel = IntroduceLabel().then {
        $0.text = "상담하고 싶은 친구를\n" +
                  "선택해주세요."
    }
    
    let counselButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("상담하기", for: .normal)
    }
    
    
    // MARK: - Properties
    
    let isFirstProcess: Bool
    
    var allCharacterButtons: [CharacterButton] {
        self.characterButtonStackView.arrangedSubviews
            .compactMap { $0 as? CharacterButton }
    }
    
    
    // MARK: - Initialize
    
    init(isFirstProcess: Bool) {
        self.isFirstProcess = isFirstProcess
        
        super.init(frame: .zero)
        
        Character.allCases.forEach { character in
            let button = CharacterButton(character: character)
            characterButtonStackView.addArrangedSubview(button)
        }
    }
    
    required init?(coder: NSCoder) {
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
        addSubview(characterButtonStackView)
        addSubview(characterIntroduceLabel)
        addSubview(counselButton)
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
            make.bottom.equalTo(secondIntroduceLabel.snp.top).offset(-Metric.firstSecondIntroduceLabelPadding)
        }
        
        secondIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.secondIntroduceLabelSuperViewPadding)
        }
        
        characterButtonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondIntroduceLabel.snp.bottom).offset(Metric.characterStackViewTopPadding)
        }
        
        characterIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(characterButtonStackView.snp.bottom).offset(Metric.characterStackViewBottomPadding)
        }
        
        counselButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Metric.counselButtonBottomPadding)
        }
    }
}


// MARK: - Animations

extension ChoosingView {
    func hideAllComponents() {
        firstIntroduceLabel.alpha = 0.0
        secondIntroduceLabel.alpha = 0.0
        characterButtonStackView.alpha = 0.0
        characterIntroduceLabel.alpha = 0.0
        
        disableCounselButton()
        disableAllCharacterButtons()
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: moonImageView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: firstIntroduceLabel,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: secondIntroduceLabel,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: characterButtonStackView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: counselButton,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: gradientView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: characterIntroduceLabel,
                                              animationCase: .fadeOut,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: moonImageView,
                                              animationCase: .moveUp(value: 35),
                                              duration: 1.5),
                                        .init(view: firstIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.8),
                                        .init(view: secondIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 2.0),
                                        .init(view: characterButtonStackView,
                                              animationCase: .fadeIn,
                                              duration: 1.5),
                                        .init(view: characterIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.8)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}

extension ChoosingView {
    func spotlight(to character: Character?) {
        guard let character else { return }
        
        deselectAllCharacterButtons()
        allCharacterButtons.forEach { characterButton in
            if characterButton.identifier == character.identifier {
                characterButton.isSelected = true
            }
        }
        characterIntroduceLabel.text = character.introduceMessage
        enableCounselButton()
    }
    
    func enableAllCharacterButtons() {
        self.allCharacterButtons
            .forEach { $0.isEnabled = true }
    }
    
    func disableAllCharacterButtons() {
        self.allCharacterButtons
            .forEach { $0.isEnabled = false }
    }
    
    func deselectAllCharacterButtons() {
        self.allCharacterButtons
            .forEach { $0.isSelected = false }
    }
    
    func enableCounselButton() {
        self.counselButton.isEnabled = true
        self.counselButton.alpha = 1.0
    }
    
    func disableCounselButton() {
        self.counselButton.isEnabled = false
        self.counselButton.alpha = 0.0
    }
}
