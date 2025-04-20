//
//  HomeView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import Lottie
import UIKit

final class HomeView: UIView {
    
    // MARK: - Metric

    private enum Metric {
        static let moonTopPadding: CGFloat = .deviceAdjustedHeight(132)
        static let ghostButtonPadding: CGFloat = .deviceAdjustedHeight(65)
        static let buttonBottomPadding: CGFloat = .deviceAdjustedHeight(266)
        
        static let ghostTalkingSpacing: CGFloat = .deviceAdjustedHeight(14)
        static let ghostTalkingRightPadding: CGFloat = .deviceAdjustedWidth(23)
        static let ghostImageRightPadding: CGFloat = .deviceAdjustedWidth(119)
        
        static let moonImageSize: CGFloat = .deviceAdjustedHeight(43)
        static let pulsingCircleSize: CGFloat = .deviceAdjustedHeight(380)
        static let ghostImageSize: CGFloat = .deviceAdjustedWidth(78)
        
        static let pulsingCircleAlpha: CGFloat = AppEnvironment.appearanceMode == .dark ? 0.3 : 0.7
        static let pulsingCircleAnimationSpeed: CGFloat = 0.3
        static let sparklingAnimationSpeed: CGFloat = 0.5
    }
    
    
    // MARK: - Views
    
    let gradientView: GradientView = GradientView(
        colors: [
            AppColor.Background.sub.color,
            AppColor.Background.main.color,
            AppColor.Background.main.color
        ]
    )
    
    let skyBadgeImageView = UIImageView().then {
        $0.image = AppImage.Component.skyBadge.image
    }
    
    let pulsingCircleLottieView = LottieAnimationView(name: AppImage.JSON.pulsingCircle.name).then {
        $0.alpha = Metric.pulsingCircleAlpha
        $0.animationSpeed = Metric.pulsingCircleAnimationSpeed
        $0.loopMode = .loop
        $0.play()
    }
    
    let sparklingLottieView = LottieAnimationView(name: AppImage.JSON.sparkles.name).then {
        $0.alpha = 1.0
        $0.animationSpeed = Metric.sparklingAnimationSpeed
        $0.contentMode = .scaleToFill
        $0.loopMode = .loop
        $0.play()
    }
    
    let ghostImageView: GhostView = GhostView().then {
        $0.isUserInteractionEnabled = false
    }
    
    let ghostTalkingView: TalkingView = TalkingView().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.isUserInteractionEnabled = false
    }
    
    let startButton = HorizontalButton().then {
        $0.setTitle("편지 쓰기", for: .normal)
    }
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        self.backgroundColor = AppColor.Background.main.color
    }
    
    private func addSubviews() {
        addSubview(gradientView)
        addSubview(pulsingCircleLottieView)
        addSubview(skyBadgeImageView)
        addSubview(sparklingLottieView)
        addSubview(ghostTalkingView)
        addSubview(ghostImageView)
        addSubview(startButton)
    }
    
    private func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        skyBadgeImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.moonTopPadding)
            make.height.equalTo(Metric.moonImageSize)
            make.width.equalTo(Metric.moonImageSize)
        }
        
        pulsingCircleLottieView.snp.makeConstraints { make in
            make.center.equalTo(skyBadgeImageView)
            make.size.equalTo(Metric.pulsingCircleSize)
        }
        
        sparklingLottieView.snp.makeConstraints { make in
            make.center.equalTo(skyBadgeImageView)
            make.width.equalToSuperview()
        }
        
        ghostTalkingView.snp.makeConstraints { make in
            make.bottom.equalTo(ghostImageView.snp.top).offset(-Metric.ghostTalkingSpacing)
            make.right.equalTo(ghostImageView.snp.right).offset(-Metric.ghostTalkingRightPadding)
        }
        
        ghostImageView.snp.makeConstraints { make in
            make.bottom.equalTo(startButton.snp.top).offset(-Metric.ghostButtonPadding)
            make.right.equalToSuperview().offset(-Metric.ghostImageRightPadding)
            make.height.equalTo(Metric.ghostImageSize)
            make.width.equalTo(Metric.ghostImageSize)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Metric.buttonBottomPadding)
        }
    }
}


// MARK: - Animations

extension HomeView {
    func hideAllComponents() {
        subviews.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeOutAllComponents(duration: TimeInterval) async {
        let animations = subviews.exclude(skyBadgeImageView, gradientView).map {
            Animation(view: $0,
                      animationCase: .fadeOut,
                      duration: duration)
        }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: animations,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAllComponentsFadeIn(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            var animations = subviews.exclude(pulsingCircleLottieView, sparklingLottieView).map {
                Animation(
                    view: $0,
                    animationCase: .fadeIn,
                    duration: duration
                )
            }
            
            animations.append(
                Animation(
                    view: pulsingCircleLottieView,
                    animationCase: .fade(value: Metric.pulsingCircleAlpha),
                    duration: duration
                )
            )
            
            animations.append(
                Animation(
                    view: sparklingLottieView,
                    animationCase: .fadeIn,
                    duration: duration
                )
            )
            
            AnimationGroup(
                animations: animations,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAppearing(direction: TabBarDirection) async {
        hideAllComponents()
        
        switch direction {
        case .left:
            self.subviews
                .exclude(gradientView)
                .forEach { $0.transform = .identity.translatedBy(x: 10, y: 0) }
        case .right:
            self.subviews
                .exclude(gradientView)
                .forEach { $0.transform = .identity.translatedBy(x: -10, y: 0) }
        }
        
        let transformAnimation = subviews.exclude(gradientView).map {
            Animation(view: $0,
                      animationCase: .transform(.identity),
                      duration: 0.2)
        }
        
        let fadeInAnimation = subviews.exclude(pulsingCircleLottieView, sparklingLottieView).map {
            Animation(view: $0,
                      animationCase: .fadeIn,
                      duration: 0.2)
        }
        
        let pulsingCircleAnimation = Animation(
            view: pulsingCircleLottieView,
            animationCase: .fade(value: Metric.pulsingCircleAlpha),
            duration: 0.2
        )
        
        let sparklingAnimation = Animation(view: sparklingLottieView,
                                           animationCase: .fadeIn,
                                           duration: 0.2)
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: transformAnimation + fadeInAnimation + [pulsingCircleAnimation, sparklingAnimation],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            )
            .run()
        }
    }
    
    @MainActor
    func playDisappearing(direction: TabBarDirection) async {
        var translationX = 0.0
        switch direction {
        case .left:
            translationX = -10
        case .right:
            translationX = 10
        }
        
        let transformAnimation = subviews.exclude(gradientView)
            .map {
            Animation(
                view: $0,
                animationCase: .transform( .init(translationX: translationX, y: 0)),
                duration: 0.2)
            }
        
        let fadeOutAnimation = subviews
            .map {
                Animation(view: $0,
                          animationCase: .fadeOut,
                          duration: 0.2)
            }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: transformAnimation + fadeOutAnimation,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
