//
//  FrameAnimationContentWithLottie.swift
//  GloomyDiary
//
//  Created by 디해 on 1/24/25.
//

import Dependencies
import Lottie
import UIKit

final class FrameAnimationContentWithLottie: UIView, AnimationContent {
    private enum Metric {
        static let starWidth: CGFloat = .deviceAdjustedHeight(300)
        static let starHeight: CGFloat = .deviceAdjustedHeight(135)
        static let readyLabelPadding: CGFloat = .deviceAdjustedHeight(50)
    }
    
    private let starLottieView = LottieAnimationView(name: "stars").then {
        $0.frame = .init(x: 0, y: 0, width: Metric.starWidth, height: Metric.starHeight)
        $0.animationSpeed = 2.0
        $0.loopMode = .loop
        $0.contentMode = .scaleToFill
        $0.alpha = 0.0
    }
    
    private let readyLabel = NormalLabel().then {
        $0.alpha = 0.0
    }
    
    let snapshot: UIView
    let initialFrame: CGRect
    let targetFrame: CGRect
    let duration: TimeInterval
    
    init?(
        _ component: UIView,
        initialFrame: CGRect,
        targetFrame: CGRect,
        duration: TimeInterval,
        character: CounselingCharacter
    ) {
        guard let snapshot = component.snapshotView(afterScreenUpdates: false) else { return nil }
        self.snapshot = snapshot
        self.initialFrame = initialFrame
        self.targetFrame = targetFrame
        self.duration = duration
        
        super.init(frame: .zero)
        
        setup()
        setupReadyLabel(character: character)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        snapshot.frame = initialFrame
        
        addSubview(starLottieView)
        addSubview(readyLabel)
        addSubview(snapshot)
        
        starLottieView.center = snapshot.center
    }
    
    private func setupReadyLabel(character: CounselingCharacter) {
        readyLabel.text = character.counselReadyMessage
        readyLabel.sizeToFit()
        readyLabel.center = CGPoint(
            x: snapshot.center.x,
            y: snapshot.center.y + snapshot.frame.height / 2 + Metric.readyLabelPadding
        )
    }

    @MainActor
    func performAnimation() async {
        starLottieView.play()
        let percentages: [CGFloat] = [20, 35, 20, 25]
        let calculatedDurations = percentages.map { duration * $0 / 100 }
        
        await playWaitingViewsFadeIn(duration: calculatedDurations[0])
        try? await Task.sleep(nanoseconds: UInt64(calculatedDurations[1] * 1_000_000_000))
        await playWaitingViewsFadeOut(duration: calculatedDurations[2])
        await playSnapshot(duration: calculatedDurations[3])
    }
    
    private func playSnapshot(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: snapshot,
                                       animationCase: .frame(targetFrame),
                                       duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            )
            .run()
        }
    }
    
    @MainActor
    private func playWaitingViewsFadeIn(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: starLottieView,
                                       animationCase: .fadeIn,
                                       duration: duration),
                             Animation(view: readyLabel,
                                       animationCase: .fadeIn,
                                       duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    private func playWaitingViewsFadeOut(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: starLottieView,
                                       animationCase: .fadeOut,
                                       duration: duration),
                             Animation(view: readyLabel,
                                       animationCase: .fadeOut,
                                       duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
