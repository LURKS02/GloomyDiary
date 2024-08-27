//
//  ChoosingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class ChoosingView: BaseView {
    private struct Matric {
        static let secondIntroduceLabelSuperViewPadding: CGFloat = 240
        static let firstSecondIntroduceLabelPadding: CGFloat = 31
        static let characterStackViewTopPadding: CGFloat = 30
        static let characterStackViewBottomPadding: CGFloat = 30
        static let stackViewSpacing: CGFloat = 11
        static let counselButtonBottomPadding: CGFloat = 60
        
        static let moonImageSize: CGFloat = 43
        static let moonTopPadding: CGFloat = 132
    }
    
    let moonImageView: ImageView = ImageView(imageName: "moon", size: 43)
    
    let gradientView: GradientView = GradientView(colors: [.background(.darkPurple),
                                                           .background(.mainPurple),
                                                           .background(.mainPurple)])
    
    let firstIntroduceLabel: IntroduceLabel = IntroduceLabel()
    
    let secondIntroduceLabel: IntroduceLabel = IntroduceLabel()
    
    let characterButtonStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = Matric.stackViewSpacing
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    let characterIntroduceLabel: IntroduceLabel = IntroduceLabel()
    
    let counselButton: ButtonView = ButtonView(text: "상담하기")
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
        let buttons = Character.allCases.enumerated().map { index, character in
            let button = CharacterButtonView(characterName: character.name,
                            characterImage: character.imageName)
            button.tag = index
            return button
        }
        
        buttons.forEach { button in
            characterButtonStackView.addArrangedSubview(button)
        }
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
