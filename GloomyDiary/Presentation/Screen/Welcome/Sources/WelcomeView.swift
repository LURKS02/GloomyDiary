//
//  WelcomeView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/20/24.
//

import UIKit
import Lottie

final class WelcomeView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let moonTopPadding: CGFloat = .deviceAdjustedHeight(132)
        static let moonImageSize: CGFloat = .deviceAdjustedWidth(43)
        static let ghostImageSize: CGFloat = .deviceAdjustedWidth(78)
        static let firstLabelTopPadding: CGFloat = .deviceAdjustedHeight(40)
        static let secondLabelTopPadding: CGFloat = .deviceAdjustedHeight(15)
        static let ghostImageViewBottomPadding: CGFloat = .deviceAdjustedHeight(300)
        static let talkingLabelBottomPadding: CGFloat = .deviceAdjustedHeight(250)
    }

    
    // MARK: - Views
    
    private let gradientView: GradientView = GradientView(
        colors: [
            AppColor.Background.darkPurple.color,
            AppColor.Background.mainPurple.color,
            AppColor.Background.mainPurple.color
        ]
    )
    
    private let moonImageView = UIImageView().then {
        $0.image = UIImage(named: "moon")
    }
    
    let ghostView = UIImageView().then {
        $0.image = UIImage(named: "ghost")
    }
    
    private let firstNormalLabel = NormalLabel().then {
        $0.text = "우리들의 다이어리"
    }
    
    private let secondNormalLabel = NormalLabel().then {
        $0.text = "\"울다\""
        $0.font = .온글잎_의연체.heading
    }
    
    private let talkingLabel = NormalLabel().then {
        $0.text = "나를 눌러봐!"
    }
    
    
    // MARK: - Properties
    
    var bounceTimer: Timer?
    
    
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
        self.backgroundColor = AppColor.Background.mainPurple.color
    }
    
    private func addSubviews() {
        addSubview(gradientView)
        addSubview(moonImageView)
        addSubview(ghostView)
        addSubview(firstNormalLabel)
        addSubview(secondNormalLabel)
        addSubview(talkingLabel)
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
        
        ghostView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Metric.ghostImageViewBottomPadding)
            make.height.equalTo(Metric.ghostImageSize)
            make.width.equalTo(Metric.ghostImageSize)
        }
        
        firstNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(moonImageView.snp.bottom).offset(Metric.firstLabelTopPadding)
        }
        
        secondNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstNormalLabel.snp.bottom).offset(Metric.secondLabelTopPadding)
        }
        
        talkingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Metric.talkingLabelBottomPadding)
        }
    }
}


// MARK: - Animations

extension WelcomeView {
    func hideAllComponents() {
        subviews.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents() async {
        await playFadeInBackground()
        await playFadeInNormalLabels()
        try? await Task.sleep(nanoseconds: 700_000_000)
        await playFadeInGhost()
    }
    
    @MainActor
    func playFadeInBackground() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: gradientView,
                              animationCase: .fadeIn,
                              duration: 1.0),
                    Animation(view: moonImageView,
                              animationCase: .fadeIn,
                              duration: 0.5)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInNormalLabels() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: firstNormalLabel,
                              animationCase: .fadeIn,
                              duration: 0.5),
                    Animation(view: secondNormalLabel,
                              animationCase: .fadeIn,
                              duration: 0.5)
                ],
                mode: .serial,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInGhost() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: ghostView,
                              animationCase: .fadeIn,
                              duration: 0.5),
                    Animation(view: talkingLabel,
                              animationCase: .fadeIn,
                              duration: 0.5)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
        
        startGhostBouncing()
    }
    
    @MainActor
    func playFadeOutAllComponents(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: moonImageView,
                              animationCase: .fadeOut,
                              duration: duration),
                    Animation(view: firstNormalLabel,
                              animationCase: .fadeOut,
                              duration: duration),
                    Animation(view: secondNormalLabel,
                              animationCase: .fadeOut,
                              duration: duration),
                    Animation(view: talkingLabel,
                              animationCase: .fadeOut,
                              duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    func startGhostBouncing() {
        bounceTimer?.invalidate()
        bounceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [self] _ in
            AnimationGroup(
                animations: [
                    Animation(view: ghostView,
                              animationCase: .transform(.identity.translatedBy(x: 0, y: -5)),
                              duration: 0.2),
                    Animation(view: ghostView,
                              animationCase: .transform(.identity),
                              duration: 0.2),
                    Animation(view: ghostView,
                              animationCase: .transform(.identity.translatedBy(x: 0, y: -5)),
                              duration: 0.2),
                    Animation(view: ghostView,
                              animationCase: .transform(.identity),
                              duration: 0.2)
                ],
                mode: .serial,
                loop: .once(completion: nil))
            .run()
        }
    }
    
    func stopGhostBouncing() {
        bounceTimer?.invalidate()
        bounceTimer = nil
    }
}
