//
//  PasswordView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import UIKit

final class PasswordView: UIView {
    
    private let titleLabel = NormalLabel().then {
        $0.text = "비밀번호 설정"
    }
    
    private let informationLabel = NormalLabel().then {
        $0.textColor = AppColor.Text.fogHighlight.color
        $0.text = """
                  새로운 비밀번호를
                  입력해주세요.
                  """
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
    
    private let totalPins: Int
    
    private var isMismatch: Bool = false
    
    
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
        addSubview(titleLabel)
        addSubview(informationLabel)
        addSubview(hiddenTextField)
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
        }
        
        informationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(informationLabel.snp.bottom).offset(60)
            make.height.equalTo(40)
            make.width.equalTo(205)
        }
    }
}

extension PasswordView {
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
    
    func configureForConfirmation() {
        informationLabel.text = """
                                다시 한 번
                                입력해주세요.
                                """
        highlightStarlights(number: 0)
        hiddenTextField.text = ""
    }
    
    func configureForMismatch() {
        isMismatch = true
        informationLabel.text = """
                                비밀번호가 틀립니다.
                                다시 입력해주세요.
                                """
        informationLabel.textColor = AppColor.Text.warning.color
        highlightStarlights(number: 0)
        hiddenTextField.text = ""
    }
}

extension PasswordView {
    @MainActor
    func playAppearingAnimation(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 0,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(
                        view: self,
                        animationCase: .fadeIn,
                        duration: duration
                    ),
                    Animation(
                        view: self,
                        animationCase: .frame(targetFrame),
                        duration: duration
                    )
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            ).run()
        }
    }
    
    @MainActor
    func playDisappearingAnimation(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 100,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(
                        view: self,
                        animationCase: .fadeOut,
                        duration: duration
                    ),
                    Animation(
                        view: self,
                        animationCase: .frame(targetFrame),
                        duration: duration
                    )
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            ).run()
        }
    }
}
