//
//  LocalNotificationView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/28/24.
//

import UIKit

final class LocalNotificationView: BaseView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let sheetHeight: CGFloat = max(.verticalValue(380), 320)
        static let sheetWidth: CGFloat = .horizontalValue(350)
        static let cornerRadius: CGFloat = .verticalValue(30)
        static let ghostSize: CGFloat = .verticalValue(70)
        static let ghostImageTopPadding: CGFloat = .verticalValue(35)
        static let notificationLabelTopPadding: CGFloat = .verticalValue(25)
        static let buttonStackViewTopPadding: CGFloat = .verticalValue(35)
        static let buttonStackViewHorizontalPadding: CGFloat = .horizontalValue(40)
    }

    
    // MARK: - Views
    
    let blurView = UIVisualEffectView()
    
    let sheetBackgroundView = UIView().then {
        $0.backgroundColor = .background(.mainPurple)
        $0.layer.cornerRadius = Metric.cornerRadius
        $0.alpha = 0.0
    }
    
    let ghostImageView = UIImageView().then {
        $0.image = UIImage(named: "ghost")
    }
    
    let notificationLabel = IntroduceLabel().then {
        $0.text = "잊어버리지 않고\n" +
                  "편지를 보낼 수 있도록\n" +
                  "울다에서 데일리 알림을 보내드릴까요?\n\n" +
                  "동물 친구들도 기뻐할 거에요!"
    }
    
    let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.distribution = .fillEqually
    }
    
    let acceptButton = HorizontalButton().then {
        $0.setTitle("좋아요!", for: .normal)
    }
    
    let rejectButton = HorizontalButton().then {
        $0.setTitle("아니요..", for: .normal)
        $0.setTitleColor(.text(.buttonSubHighlight), for: .normal)
        $0.backgroundColor = .component(.buttonDisabledPurple)
    }
    
    let checkButton = HorizontalButton().then {
        $0.setTitle("확인", for: .normal)
    }
    
    
    // MARK: - View Life Cycle

    override func addSubviews() {
        addSubview(blurView)
        addSubview(sheetBackgroundView)
        sheetBackgroundView.addSubview(ghostImageView)
        sheetBackgroundView.addSubview(notificationLabel)
        sheetBackgroundView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(rejectButton)
        buttonStackView.addArrangedSubview(acceptButton)
    }
    
    override func setupConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sheetBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(Metric.sheetHeight)
            make.width.equalTo(Metric.sheetWidth)
        }
        
        ghostImageView.snp.makeConstraints { make in
            make.width.equalTo(Metric.ghostSize)
            make.height.equalTo(Metric.ghostSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.ghostImageTopPadding)
        }
        
        notificationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ghostImageView.snp.bottom)
                .offset(Metric.notificationLabelTopPadding)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(notificationLabel.snp.bottom).offset(Metric.buttonStackViewTopPadding)
            make.horizontalEdges.equalToSuperview().inset(Metric.buttonStackViewHorizontalPadding)
        }
    }
}

extension LocalNotificationView {
    @MainActor
    func runAppearanceAnimation() async {
        sheetBackgroundView.transform = .identity.scaledBy(x: 0.75, y: 0.75)
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: blurView,
                                              animationCase: .custom(closure: { view in
                guard let view = view as? UIVisualEffectView else { return }
                view.effect = UIBlurEffect(style: .dark)
            }), duration: 0.3),
                                        .init(view: sheetBackgroundView,
                                              animationCase: .transform(transform: .identity), duration: 0.3),
                                        .init(view: sheetBackgroundView,
                                              animationCase: .fadeIn,
                                              duration: 0.3)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func runDismissAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: blurView,
                                              animationCase: .custom(closure: { view in
                guard let view = view as? UIVisualEffectView else { return }
                view.effect = nil
            }), duration: 0.3),
                                        .init(view: sheetBackgroundView,
                                              animationCase: .transform(transform: .identity.scaledBy(x: 0.75, y: 0.75)),
                                              duration: 0.3),
                                        .init(view: sheetBackgroundView,
                                              animationCase: .fadeOut,
                                              duration: 0.3)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func runFadeOutLeftAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: sheetBackgroundView.subviews.map { Animation(view: $0,
                                                                                    animationCase: .transform(transform: .identity.translatedBy(x: -20, y: 0)),
                                                                                    duration: 0.3) }
                           + sheetBackgroundView.subviews.map { Animation(view: $0,
                                                                          animationCase: .fadeOut,
                                                                          duration: 0.3) },
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func showAcceptResult() async {
        ghostImageView.image = UIImage(named: "happyGhost")
        notificationLabel.text = "알림이 설정되었어요!\n\n" +
                                 "이제 울다에서\n" +
                                 "데일리 알림을 보내드릴게요.\n" +
                                 "잊지 말고 방문하세요!"
        buttonStackView.subviews.forEach { $0.removeFromSuperview() }
        buttonStackView.addArrangedSubview(checkButton)
        
        sheetBackgroundView.subviews.forEach { $0.transform = .identity.translatedBy(x: 20, y: 0) }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: sheetBackgroundView.subviews.map { Animation(view: $0,
                                                                                    animationCase: .transform(transform: .identity),
                                                                                    duration: 0.3) } + sheetBackgroundView.subviews.map { Animation(view: $0,
                                                                                                                                                    animationCase: .fadeIn,
                                                                                                                                                    duration: 0.3) },
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func showRejectResult() async {
        ghostImageView.image = UIImage(named: "cryingGhost")
        notificationLabel.text = "알림을 거절했어요.\n\n" +
                                 "설정 > 앱 > 울다 > 알림 에서\n" +
                                 "[알림 허용] 을 눌러\n" +
                                 "언제든 다시 알림을 설정할 수 있어요!"
        buttonStackView.subviews.forEach { $0.removeFromSuperview() }
        buttonStackView.addArrangedSubview(checkButton)
        
        sheetBackgroundView.subviews.forEach { $0.transform = .identity.translatedBy(x: 20, y: 0) }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: sheetBackgroundView.subviews.map { Animation(view: $0,
                                                                                    animationCase: .transform(transform: .identity),
                                                                                    duration: 0.3) } + sheetBackgroundView.subviews.map { Animation(view: $0,
                                                                                                                                                    animationCase: .fadeIn,
                                                                                                                                                    duration: 0.3) },
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
