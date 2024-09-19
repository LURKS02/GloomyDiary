//
//  ChoosingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class ChoosingView: BaseView {
    struct Matric {
        static let secondIntroduceLabelSuperViewPadding: CGFloat = 240
        static let firstSecondIntroduceLabelPadding: CGFloat = 31
        static let characterStackViewTopPadding: CGFloat = 30
        static let characterStackViewBottomPadding: CGFloat = 30
        static let stackViewSpacing: CGFloat = 11
        static let counselButtonBottomPadding: CGFloat = 60
        
        static let moonImageSize: CGFloat = 43
        static let moonTopPadding: CGFloat = 132
    }
    
    private let moonImageView: ImageView = ImageView().then {
        $0.setImage("moon")
        $0.setSize(43)
    }
    
    private let gradientView: GradientView = GradientView(colors: [.background(.darkPurple),
                                                                   .background(.mainPurple),
                                                                   .background(.mainPurple)])
    
    private lazy var firstIntroduceLabel: IntroduceLabel = IntroduceLabel()
    
    private lazy var secondIntroduceLabel: IntroduceLabel = IntroduceLabel()
    
    private let characterButtonStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = Matric.stackViewSpacing
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    let characterIntroduceLabel: IntroduceLabel = IntroduceLabel()
    
    let counselButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("상담하기", for: .normal)
    }
    
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
            make.top.equalToSuperview().offset(Matric.moonTopPadding)
        }
        
        firstIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(secondIntroduceLabel.snp.top).offset(-Matric.firstSecondIntroduceLabelPadding)
        }
        
        secondIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Matric.secondIntroduceLabelSuperViewPadding)
        }
        
        characterButtonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondIntroduceLabel.snp.bottom).offset(Matric.characterStackViewTopPadding)
        }
        
        characterIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(characterButtonStackView.snp.bottom).offset(Matric.characterStackViewBottomPadding)
        }
        
        counselButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Matric.counselButtonBottomPadding)
        }
    }
}


// MARK: - Sugar

extension ChoosingView {
    var allCharacterButtons: [CharacterButton] {
        self.characterButtonStackView.arrangedSubviews
            .compactMap { $0 as? CharacterButton }
    }
}


// MARK: - functions

extension ChoosingView {
    func addCharactersToStack(_ characters: [Character]) {
        characterButtonStackView.removeAllArrangedSubviews()
        
        characters.enumerated().map { index, character in
            CharacterButton(character: character).then { $0.tag = index }
        }.forEach { characterButtonStackView.addArrangedSubview($0) }
    }
    
    func hideAllComponents() {
        firstIntroduceLabel.alpha = 0.0
        secondIntroduceLabel.alpha = 0.0
        characterButtonStackView.alpha = 0.0
        characterIntroduceLabel.alpha = 0.0
        
        disableCounselButton()
        disableAllCharacterButtons()
    }
    
    func removeAllComponents(completion: @escaping () -> Void) {
        AnimationManager.shared.run(animations: [
            .init(view: moonImageView,
                  type: .fadeInOut(value: 0.0),
                  duration: 1.0)
        ], mode: .once)
        AnimationManager.shared.run(animations: [
            .init(view: firstIntroduceLabel,
                  type: .fadeInOut(value: 0.0),
                  duration: 1.0)
        ], mode: .once)
        AnimationManager.shared.run(animations: [
            .init(view: secondIntroduceLabel,
                  type: .fadeInOut(value: 0.0),
                  duration: 1.0)
        ], mode: .once)
        AnimationManager.shared.run(animations: [
            .init(view: characterButtonStackView,
                  type: .fadeInOut(value: 0.0),
                  duration: 1.0)
        ], mode: .once)
        AnimationManager.shared.run(animations: [
            .init(view: counselButton,
                  type: .fadeInOut(value: 0.0),
                  duration: 1.0)
        
        ], mode: .once)
        AnimationManager.shared.run(animations: [
            .init(view: gradientView,
                  type: .fadeInOut(value: 0.0),
                  duration: 1.0)
        ], mode: .once)
        AnimationManager.shared.run(animations: [
            .init(view: characterIntroduceLabel,
                  type: .fadeInOut(value: 0.0),
                  duration: 1.0,
                  completion: {
                      completion()
                  })
        ], mode: .once)
    }
    
    func showAllComponents() {
        AnimationManager.shared.run(animations: [
            .init(view: moonImageView,
                  type: .moveUp(value: 35),
                  duration: 1.5),
            .init(view: firstIntroduceLabel,
                  type: .fadeInOut(value: 1.0),
                  duration: 1.8),
            .init(view: secondIntroduceLabel,
                  type: .fadeInOut(value: 1.0),
                  duration: 2.0),
            .init(view: characterButtonStackView,
                  type: .fadeInOut(value: 1.0),
                  duration: 1.5),
            .init(view: characterIntroduceLabel,
                  type: .fadeInOut(value: 1.0),
                  duration: 1.8,
                  completion: { [weak self] in
                      self?.enableAllCharacterButtons()
                  })
        ],
                                    mode: .once)
    }
    
    func setMessage(isFirst: Bool) {
        if isFirst {
            firstIntroduceLabel.text = "첫 번째 상담을 진행해볼까요?"
            secondIntroduceLabel.text = "\"울다\"에는\n"
                                      + "여러분들의 이야기를 들어줄\n"
                                      + "세 마리의 상담사가 있어요."
        } else {
            firstIntroduceLabel.text = "반가워요!"
            secondIntroduceLabel.text = "오늘은 어떤 일이 있었나요?\n"
                                      + "당신의 이야기를 들려주세요."
        }
    }
    
    func setCharacterIntroduceMessage(character: Character?) {
        if character == nil {
            characterIntroduceLabel.text = "상담하고 싶은 친구를\n"
                                         + "선택해주세요."
        } else {
            characterIntroduceLabel.text = character?.introduceMessage
        }
    }
    
    func enableAllCharacterButtons() {
        self.allCharacterButtons
            .forEach { $0.isEnabled = true }
    }
    
    func disableAllCharacterButtons() {
        self.allCharacterButtons
            .forEach { $0.isEnabled = false }
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
