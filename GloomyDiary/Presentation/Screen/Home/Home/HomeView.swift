//
//  HomeView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import Lottie

final class HomeView: BaseView {
    
    // MARK: - Metric

    private struct Metric {
        static let moonTopPadding: CGFloat = 132
        static let ghostButtonPadding: CGFloat = 65
        static let buttonBottomPadding: CGFloat = 266
        
        static let ghostTalkingSpacing: CGFloat = 14
        static let ghostTalkingRightPadding: CGFloat = 23
        static let ghostImageRightPadding: CGFloat = 119
        
        static let moonImageSize: CGFloat = 43
        static let pulsingCircleSize: CGFloat = 380
        static let ghostImageSize: CGFloat = 78
        
        static let pulsingCircleAlpha: CGFloat = 0.3
        static let pulsingCircleAnimationSpeed: CGFloat = 0.3
        static let sparklingAlpha: CGFloat = 0.3
        static let sparklingAnimationSpeed: CGFloat = 0.5
    }
    
    
    // MARK: - Views
    
    let gradientView: GradientView = GradientView(colors: [.background(.darkPurple),
                                                           .background(.mainPurple),
                                                           .background(.mainPurple)])
    
    let moonImageView: ImageView = ImageView().then {
        $0.setImage("moon")
        $0.setSize(Metric.moonImageSize)
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
        $0.setImage("ghost")
        $0.setSize(Metric.ghostImageSize)
    }
    
    let ghostTalkingView: TalkingView = TalkingView().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    let startButton = HorizontalButton().then {
        $0.setTitle("상담하기", for: .normal)
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(moonImageView)
        addSubview(pulsingCircleLottieView)
        addSubview(sparklingLottieView)
        addSubview(ghostTalkingView)
        addSubview(ghostImageView)
        addSubview(startButton)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moonImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.moonTopPadding)
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
        ghostTalkingView.alpha = 0.0
        sparklingLottieView.alpha = 0.0
        startButton.alpha = 0.0
        ghostImageView.alpha = 0.0
        pulsingCircleLottieView.alpha = 0.0
        moonImageView.alpha = 0.0
        gradientView.alpha = 0.0
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: self.ghostTalkingView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: self.sparklingLottieView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: self.startButton,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: self.ghostImageView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: self.pulsingCircleLottieView,
                                              animationCase: .fadeOut,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAllComponentsFadeIn() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: self.ghostTalkingView,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: self.sparklingLottieView,
                                              animationCase: .fade(value: Metric.sparklingAlpha),
                                              duration: 1.0),
                                        .init(view: self.startButton,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: self.ghostImageView,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: self.pulsingCircleLottieView,
                                              animationCase: .fade(value: Metric.pulsingCircleAlpha),
                                              duration: 1.0),
                                        .init(view: self.moonImageView,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: gradientView,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
