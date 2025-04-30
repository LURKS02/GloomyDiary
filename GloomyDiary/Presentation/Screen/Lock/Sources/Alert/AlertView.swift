//
//  AlertView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import UIKit

final class AlertView: UIView {
    let backgroundView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.alpha = 0.0
    }
    
    private let sheetBackgroundView = UIView().then {
        $0.backgroundColor = AppColor.Background.main.color
        $0.layer.cornerRadius = .deviceAdjustedHeight(30)
        $0.alpha = 0.0
    }
    
    private let notificationLabel = NormalLabel().then {
        $0.text = """
                  정말 비밀번호를 해제할까요?
                  """
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.distribution = .fillEqually
    }
    
    let acceptButton = NormalHorizontalButton().then {
        $0.setTitle("네", for: .normal)
    }
    
    let rejectButton = RejectHorizontalButton().then {
        $0.setTitle("아니오", for: .normal)
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(backgroundView)
        addSubview(sheetBackgroundView)
        sheetBackgroundView.addSubview(notificationLabel)
        sheetBackgroundView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(acceptButton)
        buttonStackView.addArrangedSubview(rejectButton)
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sheetBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(CGFloat.deviceAdjustedWidth(20))
        }
        
        notificationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(notificationLabel.snp.bottom).offset(CGFloat.deviceAdjustedHeight(25))
            make.horizontalEdges.equalToSuperview().inset(CGFloat.deviceAdjustedWidth(40))
            make.bottom.equalToSuperview().inset(CGFloat.deviceAdjustedHeight(25))
        }
    }
}

extension AlertView {
    @MainActor
    func playFadeInAnimation() async {
        sheetBackgroundView.transform = .identity.scaledBy(x: 0.75, y: 0.75)
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: backgroundView,
                              animationCase: .fadeIn,
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .transform( .identity),
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .fadeIn,
                              duration: 0.3)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: backgroundView,
                              animationCase: .fadeOut,
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .transform(.identity.scaledBy(x: 0.75, y: 0.75)),
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .fadeOut,
                              duration: 0.3)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
