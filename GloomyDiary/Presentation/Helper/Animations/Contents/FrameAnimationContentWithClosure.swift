//
//  FrameAnimationContentWithClosure.swift
//  GloomyDiary
//
//  Created by 디해 on 1/24/25.
//

import Dependencies
import Lottie
import UIKit

final class FrameAnimationContentWithClosure: UIView, AnimationContent {
    private enum Metric {
        static let starWidth: CGFloat = .deviceAdjustedHeight(300)
        static let starHeight: CGFloat = .deviceAdjustedHeight(135)
        static let readyLabelPadding: CGFloat = .deviceAdjustedHeight(50)
        static let middleY: CGFloat = .deviceAdjustedHeight(250)
    }
    
    private let starLottieView = LottieAnimationView(name: AppImage.JSON.stars.name).then {
        $0.frame = .init(x: 0, y: 0, width: Metric.starWidth, height: Metric.starHeight)
        $0.animationSpeed = 2.0
        $0.loopMode = .loop
        $0.contentMode = .scaleToFill
        $0.alpha = 0.0
    }
    
    private let readyLabel = NormalLabel().then {
        $0.alpha = 0.0
    }
    
    let component: UIView
    let initialFrame: CGRect
    var successFrame: CGRect
    var failureFrame: CGRect
    let duration: TimeInterval
    let perform: (() async throws -> Session)
    let completion: ((Session?) -> CGRect)?
    
    let middleFrame: CGRect
    
    @Dependency(\.logger) var logger
    
    init?(
        _ component: UIView,
        initialFrame: CGRect,
        successFrame: CGRect,
        failureFrame: CGRect,
        duration: TimeInterval,
        character: CounselingCharacter,
        perform: @escaping (() async throws -> Session),
        completion: ((Session?) -> CGRect)?
    ) {
        self.component = component
        self.initialFrame = initialFrame
        self.successFrame = successFrame
        self.failureFrame = failureFrame
        self.duration = duration
        self.perform = perform
        self.completion = completion
        
        let scaledWidth: CGFloat = 110.0
        let scaledHeight: CGFloat = (initialFrame.height * scaledWidth) / initialFrame.width
        
        middleFrame = CGRect(
            x: (UIView.screenWidth - scaledWidth) / 2,
            y: Metric.middleY,
            width: scaledWidth,
            height: scaledHeight
        )
        
        super.init(frame: .zero)
        
        component.translatesAutoresizingMaskIntoConstraints = true
        addSubview(starLottieView)
        addSubview(readyLabel)
        
        starLottieView.center = CGPoint(
            x: UIView.screenWidth / 2,
            y: middleFrame.minY + scaledHeight / 2
        )
        
        setupReadyLabel(character: character)
        readyLabel.center = CGPoint(
            x: UIView.screenWidth / 2,
            y: middleFrame.maxY + .deviceAdjustedHeight(50)
        )
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFrame(successFrame: CGRect, failureFrame: CGRect) {
        self.successFrame = successFrame
        self.failureFrame = failureFrame
    }
    
    private func setupReadyLabel(character: CounselingCharacter) {
        readyLabel.text = character.counselReadyMessage
        readyLabel.sizeToFit()
    }
    
    private func bind() {
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
    
    private func changeThemeIfNeeded() {
        starLottieView.animation = LottieAnimation.named(AppImage.JSON.stars.name)
        starLottieView.play()
        
        readyLabel.changeThemeIfNeeded()
    }

    @MainActor
    func performAnimation() async {
        let percentages: [CGFloat] = [20, 35, 20, 25]
        let calculatedDurations = percentages.map { duration * $0 / 100 }
        
        await playSnapshot(duration: calculatedDurations[0], targetFrame: middleFrame)
        starLottieView.play()
        await playWaitingViewsFadeIn(duration: calculatedDurations[1])
        
        let response: Session? = await {
            do {
                return try await perform()
            } catch {
                self.logger.send(.system, error.localizedDescription, nil)
                return nil
            }
        }()
        
        if let completion {
            if let response {
                successFrame = completion(response)
            } else {
                failureFrame = completion(nil)
            }
        }
        
        await playWaitingViewsFadeOut(duration: calculatedDurations[2])
        await playSnapshot(
            duration: calculatedDurations[3],
            targetFrame: (response != nil) ? successFrame : failureFrame
        )
        
        component.frame = initialFrame
        component.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func playSnapshot(duration: TimeInterval, targetFrame: CGRect) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: component,
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
                animations: [
                    Animation(view: starLottieView,
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
                animations: [
                    Animation(view: starLottieView,
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
