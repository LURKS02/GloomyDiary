//
//  HomeView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import Lottie

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
        
        static let pulsingCircleAlpha: CGFloat = 0.3
        static let pulsingCircleAnimationSpeed: CGFloat = 0.3
        static let sparklingAlpha: CGFloat = 0.3
        static let sparklingAnimationSpeed: CGFloat = 0.5
    }
    
    
    // MARK: - Views
    
    let gradientView: GradientView = GradientView(colors: [.background(.darkPurple),
                                                           .background(.mainPurple),
                                                           .background(.mainPurple)])
    
    let moonImageView = UIImageView().then {
        $0.image = UIImage(named: "moon")
    }
    
    let pulsingCircleLottieView = LottieAnimationView(name: "pulsingCircle").then {
        $0.alpha = Metric.pulsingCircleAlpha
        $0.animationSpeed = Metric.pulsingCircleAnimationSpeed
        $0.loopMode = .loop
        $0.play()
    }
    
    let sparklingLottieView = LottieAnimationView(name: "sparkles").then {
        $0.alpha = Metric.sparklingAlpha
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
        self.backgroundColor = .background(.mainPurple)
    }
    
    private func addSubviews() {
        addSubview(gradientView)
        addSubview(moonImageView)
        addSubview(pulsingCircleLottieView)
        addSubview(sparklingLottieView)
        addSubview(ghostTalkingView)
        addSubview(ghostImageView)
        addSubview(startButton)
    }
    
    private func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moonImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.moonTopPadding)
            make.height.equalTo(Metric.moonImageSize)
            make.width.equalTo(Metric.moonImageSize)
        }
        
        pulsingCircleLottieView.snp.makeConstraints { make in
            make.center.equalTo(moonImageView)
            make.size.equalTo(Metric.pulsingCircleSize)
        }
        
        sparklingLottieView.snp.makeConstraints { make in
            make.center.equalTo(moonImageView)
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
        let animations = subviews.exclude(moonImageView, gradientView).map {
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
                    animationCase: .fade(value: Metric.sparklingAlpha),
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
    func playAppearingFromLeft() async {
        hideAllComponents()
        
        self.subviews
            .exclude(gradientView)
            .forEach { $0.transform = .identity.translatedBy(x: -10, y: 0) }
        
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
        
        let pulsingCircleAnimation = Animation(view: pulsingCircleLottieView,
                                               animationCase: .fade(value: Metric.pulsingCircleAlpha),
                                               duration: 0.2)
        
        let sparklingAnimation = Animation(view: sparklingLottieView,
                                           animationCase: .fade(value: Metric.sparklingAlpha),
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
    func playDisappearingToRight() async {
        let transformAnimation = subviews.exclude(gradientView)
            .map {
            Animation(view: $0,
                      animationCase: .transform( .init(translationX: 10, y: 0)),
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
