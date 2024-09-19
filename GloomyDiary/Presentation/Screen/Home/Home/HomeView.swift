//
//  HomeView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import Lottie

final class HomeView: BaseView {
    struct Matric {
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
    
    let gradientView: GradientView = GradientView(colors: [.background(.darkPurple),
                                                           .background(.mainPurple),
                                                           .background(.mainPurple)])
    
    private let moonImageView: ImageView = ImageView().then {
        $0.setImage("moon")
        $0.setSize(Matric.moonImageSize)
    }
    
    let pulsingCircleLottieView = LottieAnimationView(name: "pulsingCircle").then {
        $0.alpha = Matric.pulsingCircleAlpha
        $0.animationSpeed = Matric.pulsingCircleAnimationSpeed
        $0.loopMode = .loop
        $0.play()
    }
    
    let sparklingLottieView = LottieAnimationView(name: "sparkles").then {
        $0.alpha = Matric.sparklingAlpha
        $0.animationSpeed = Matric.sparklingAnimationSpeed
        $0.contentMode = .scaleToFill
        $0.loopMode = .loop
        $0.play()
    }
    
    let ghostImageView: GhostView = GhostView().then {
        $0.setImage("ghost")
        $0.setSize(Matric.ghostImageSize)
    }
    
    let talkingView: TalkingView = TalkingView().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    let startButton = HorizontalButton().then {
        $0.setTitle("상담하기", for: .normal)
    }
    
    override func setup() {
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(moonImageView)
        addSubview(pulsingCircleLottieView)
        addSubview(sparklingLottieView)
        addSubview(talkingView)
        addSubview(ghostImageView)
        addSubview(startButton)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moonImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Matric.moonTopPadding)
        }
        
        pulsingCircleLottieView.snp.makeConstraints { make in
            make.center.equalTo(moonImageView)
            make.size.equalTo(Matric.pulsingCircleSize)
        }
        
        sparklingLottieView.snp.makeConstraints { make in
            make.center.equalTo(moonImageView)
            make.width.equalToSuperview()
        }
        
        talkingView.snp.makeConstraints { make in
            make.bottom.equalTo(ghostImageView.snp.top).offset(-Matric.ghostTalkingSpacing)
            make.right.equalTo(ghostImageView.snp.right).offset(-Matric.ghostTalkingRightPadding)
        }
        
        ghostImageView.snp.makeConstraints { make in
            make.bottom.equalTo(startButton.snp.top).offset(-Matric.ghostButtonPadding)
            make.right.equalToSuperview().offset(-Matric.ghostImageRightPadding)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Matric.buttonBottomPadding)
        }
    }
}
