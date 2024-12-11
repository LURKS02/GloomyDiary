//
//  WelcomeView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/20/24.
//

import UIKit
import Lottie

final class WelcomeView: BaseView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let moonTopPadding: CGFloat = .verticalValue(132)
        static let moonImageSize: CGFloat = .horizontalValue(43)
        static let ghostImageSize: CGFloat = .horizontalValue(78)
        static let firstLabelTopPadding: CGFloat = .verticalValue(40)
        static let secondLabelTopPadding: CGFloat = .verticalValue(15)
        static let ghostImageViewBottomPadding: CGFloat = .verticalValue(300)
    }

    
    let gradientView: GradientView = GradientView(colors: [.background(.darkPurple), .background(.mainPurple), .background(.mainPurple)])
    
    let moonImageView: ImageView = ImageView().then {
        $0.setImage("moon")
        $0.setSize(Metric.moonImageSize)
    }
    
    let ghostImageView: GhostView = GhostView().then {
        $0.setImage("ghost")
        $0.setSize(Metric.ghostImageSize)
    }
    
    let firstIntroduceLabel = IntroduceLabel().then {
        $0.text = "우리들의 다이어리"
    }
    
    let secondIntroduceLabel = IntroduceLabel().then {
        $0.text = "\"울다\""
        $0.font = .온글잎_의연체.heading
    }
    
    var bounceTimer: Timer?
    
    // MARK: - View Life Cycle
    
    override func setup() {
        self.backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(moonImageView)
        addSubview(ghostImageView)
        addSubview(firstIntroduceLabel)
        addSubview(secondIntroduceLabel)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moonImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.moonTopPadding)
        }
        
        firstIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(moonImageView.snp.bottom).offset(Metric.firstLabelTopPadding)
        }
        
        secondIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstIntroduceLabel.snp.bottom).offset(Metric.secondLabelTopPadding)
        }
        
        ghostImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Metric.ghostImageViewBottomPadding)
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
        await playFadeInIntroduceLabels()
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await playFadeInGhost()
    }
    
    @MainActor
    func playFadeInBackground() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: gradientView,
                                              animationCase: .fadeIn,
                                              duration: 2.0),
                                        .init(view: moonImageView,
                                              animationCase: .fadeIn,
                                              duration: 2.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInIntroduceLabels() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: firstIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.5),
                                        .init(view: secondIntroduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.5)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInGhost() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: ghostImageView,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
        startGhostBouncing()
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: moonImageView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: firstIntroduceLabel,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: secondIntroduceLabel,
                                              animationCase: .fadeOut,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}

extension WelcomeView {
    func startGhostBouncing() {
        bounceTimer?.invalidate()
        bounceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            AnimationGroup(animations: [.init(view: self.ghostImageView,
                                              animationCase: .transform(transform: .identity.translatedBy(x: 0, y: -5)),
                                              duration: 0.2),
                                        .init(view: self.ghostImageView,
                                              animationCase: .transform(transform: .identity),
                                              duration: 0.2),
                                        .init(view: self.ghostImageView,
                                              animationCase: .transform(transform: .identity.translatedBy(x: 0, y: -5)),
                                              duration: 0.2),
                                        .init(view: self.ghostImageView,
                                              animationCase: .transform(transform: .identity),
                                              duration: 0.2)],
                           mode: .serial, loop: .once(completion: nil))
            .run()
        }
    }
    
    func stopGhostBouncing() {
        bounceTimer?.invalidate()
        bounceTimer = nil
    }
}
