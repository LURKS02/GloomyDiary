//
//  RecoveryHintView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import UIKit

final class RecoveryHintView: UIView {
    
    private let titleLabel = NormalLabel().then {
        $0.text = "비밀번호 힌트"
    }
    
    private let informationLabel = NormalLabel().then {
        $0.textColor = AppColor.Text.fogHighlight.color
        $0.text = """
                  (옵션)
                  비밀번호를 잊어버렸을 때
                  사용할 힌트를 입력해주세요.
                  """
    }
    
    let hintTextField = RoundTextField()
    
    let warningLabel = UILabel().then {
        $0.textColor = AppColor.Text.warning.color
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .center
    }
    
    let nextButton = SubHorizontalButton().then {
        $0.setTitle("완료", for: .normal)
    }
    
    init() {
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
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(informationLabel)
        addSubview(hintTextField)
        addSubview(nextButton)
        addSubview(warningLabel)
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
        
        hintTextField.snp.makeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(CGFloat.deviceAdjustedWidth(312))
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(hintTextField.snp.bottom).offset(20)
            make.leading.equalTo(hintTextField.snp.leading).offset(10)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(hintTextField.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
        }
    }
}

extension RecoveryHintView {
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
