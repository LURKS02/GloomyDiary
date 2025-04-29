//
//  LockView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import UIKit

final class LockView: UIView {
    
    private let characterImageView = UIImageView()
    
    private let informationLabel = NormalLabel().then {
        $0.textColor = AppColor.Text.fogHighlight.color
        $0.text = "비밀번호를\n입력해주세요."
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 15
    }
    
    private var starlightViews: [StarlightView] = []
    
    let hiddenTextField = UITextField().then {
        $0.keyboardType = .numberPad
        $0.isHidden = true
    }
    
    let hintButton: UIButton = UIButton().then {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.온글잎_의연체.body,
            .foregroundColor: AppColor.Text.subHighlight.color,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedTitle = NSAttributedString(string: "잊어버렸어요", attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private let hintLabel = NormalLabel().then {
        $0.isHidden = true
        $0.textColor = AppColor.Text.fogHighlight.color
    }
    
    private let totalPins: Int
    
    private var isMismatch: Bool = false
    
    private let randomCharacter: CounselingCharacter = .getRandomElement()
    
    // MARK: - Initialize
    
    init(totalPins: Int) {
        self.totalPins = totalPins
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = AppColor.Background.letter.color
        characterImageView.image = AppImage.Character.counselor(randomCharacter, .normal).image
        setupStarlights()
    }
    
    private func setupStarlights() {
        for _ in 0..<totalPins {
            let starlightView = StarlightView()
            stackView.addArrangedSubview(starlightView)
            starlightViews.append(starlightView)
        }
    }
    
    private func addSubviews() {
        addSubview(characterImageView)
        addSubview(informationLabel)
        addSubview(hiddenTextField)
        addSubview(stackView)
        addSubview(hintButton)
        addSubview(hintLabel)
    }
    
    private func setupConstraints() {
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(50)
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }
        
        informationLabel.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(informationLabel.snp.bottom).offset(40)
            make.height.equalTo(40)
            make.width.equalTo(205)
        }
        
        hintButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(20)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(20)
        }
    }
}

extension LockView {
    func makeTextFieldFirstResponder() {
        hiddenTextField.becomeFirstResponder()
    }
    
    func highlightStarlights(number: Int) {
        starlightViews.enumerated().forEach { (index, view) in
            if index < number {
                view.isSelected = true
            } else {
                view.isSelected = false
            }
        }
    }
    
    func configureForMismatch() {
        isMismatch = true
        informationLabel.text = """
                                비밀번호가 틀렸습니다.
                                다시 입력해주세요.
                                """
        informationLabel.textColor = AppColor.Text.warning.color
        highlightStarlights(number: 0)
        hiddenTextField.text = ""
    }
    
    func showHint(_ hint: String) {
        hintButton.isHidden = true
        hintLabel.text = hint
        hintLabel.isHidden = false
    }
}
