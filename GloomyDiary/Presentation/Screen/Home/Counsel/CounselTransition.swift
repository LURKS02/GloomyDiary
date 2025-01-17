//
//  CounselTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import Dependencies
import Lottie
import UIKit

final class CounselTransition: NSObject {
    @Dependency(\.logger) var logger
    
    private enum Metric {
        static let dummyViewMiddleY: CGFloat = .verticalValue(250)
        static let readyLabelCenterY: CGFloat = .verticalValue(450)
    }
    
    private let animationClosure: () async throws -> String
    
    private let starLottieView = LottieAnimationView(name: "stars").then {
        $0.animationSpeed = 2.0
        $0.loopMode = .loop
        $0.contentMode = .scaleToFill
    }
    
    private let readyLabel = IntroduceLabel()
    
    init(animationClosure: @escaping () async throws -> String) {
        self.animationClosure = animationClosure
    }
}

extension CounselTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 3.4
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) as? CounselingView,
              let toView = transitionContext.view(forKey: .to) as? ResultView,
              let fromViewController = transitionContext.viewController(forKey: .from) as? CounselingViewController,
              let toViewController = transitionContext.viewController(forKey: .to) as? ResultViewController
        else { return }
        
        let character = fromViewController.store.character
        let characterImageView = fromView.characterImageView
        let originalFrame = characterImageView.frame
        characterImageView.translatesAutoresizingMaskIntoConstraints = true
        
        containerView.addSubview(fromView)
        
        Task { @MainActor in
            readyLabel.text = character.counselWaitingMessage
            readyLabel.sizeToFit()
            
            await fromView.removeAllComponents()
            
            containerView.addSubview(starLottieView)
            containerView.addSubview(readyLabel)
            
            let containerViewWidth = containerView.bounds.width
            
            toView.alpha = 0.0
            containerView.addSubview(toView)
            
            let dummyViewScaledWidth = 110.0
            let dummyViewScaledHeight = (characterImageView.bounds.height * dummyViewScaledWidth) / characterImageView.bounds.width
            let dummyViewMiddleFrame = CGRect(x: (containerViewWidth - dummyViewScaledWidth) / 2,
                                              y: Metric.dummyViewMiddleY,
                                              width: dummyViewScaledWidth,
                                              height: dummyViewScaledHeight)
            starLottieView.center = CGPoint(x: containerViewWidth / 2,
                                            y: dummyViewMiddleFrame.minY + dummyViewScaledHeight / 2)
            readyLabel.center = CGPoint(x: containerViewWidth / 2,
                                        y: dummyViewMiddleFrame.maxY + .verticalValue(50))
            starLottieView.alpha = 0.0
            readyLabel.alpha = 0.0
            
            
            await playDummyViewResize(characterImageView, frame: dummyViewMiddleFrame)
            starLottieView.play()
            await playWaitingViewsFadeIn()
            
            let response: String? = await {
                do {
                    return try await animationClosure()
                } catch {
                    self.logger.send(.system, error.localizedDescription, nil)
                    return nil
                }
            }()
            
            let isValidResponse = !(response?.isEmpty ?? true)
            var resultFrame = CGRect.zero
            
            if let response,
               isValidResponse {
                toViewController.hasValidResult = true
                toView.layoutIfNeeded()
                resultFrame = toView.validResultView.characterImageView.frame
                
                toViewController.store.send(.updateResponse(response))
            } else {
                toViewController.hasValidResult = false
                toView.layoutIfNeeded()
                resultFrame = toView.errorResultView.characterImageView.frame
            }
            
            await playWaitingViewsFadeOut()
            await playDummyViewResize(characterImageView, frame: resultFrame)
            
            starLottieView.removeFromSuperview()
            readyLabel.removeFromSuperview()
            toView.alpha = 1.0
            if isValidResponse {
                await toView.animateValidResult()
            } else {
                await toView.animateErrorResult()
            }
            
            characterImageView.frame = originalFrame
            characterImageView.translatesAutoresizingMaskIntoConstraints = false
            transitionContext.completeTransition(true)
        }
    }
}

private extension CounselTransition {
    @MainActor
    func playDummyViewResize(_ view: UIView, frame: CGRect) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: view,
                                              animationCase: .redraw(frame: frame),
                                              duration: 0.7)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playWaitingViewsFadeIn() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: starLottieView,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: readyLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playWaitingViewsFadeOut() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: starLottieView,
                                              animationCase: .fadeOut,
                                              duration: 0.5),
                                        .init(view: readyLabel,
                                              animationCase: .fadeOut,
                                              duration: 0.5)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
