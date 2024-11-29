//
//  CounselTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import UIKit
import Lottie

final class CounselTransition: NSObject {
    
    private let animationClosure: () async throws -> String
    
    private let starLottieView = LottieAnimationView(name: "stars").then {
        $0.animationSpeed = 2.0
        $0.loopMode = .loop
        $0.contentMode = .scaleToFill
        $0.play()
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
            starLottieView.center = CGPoint(x: containerViewWidth / 2,
                                            y: 300)
            readyLabel.center = CGPoint(x: containerViewWidth / 2,
                                        y: 430)
            starLottieView.alpha = 0.0
            readyLabel.alpha = 0.0
            
            toView.alpha = 0.0
            containerView.addSubview(toView)
            toView.layoutIfNeeded()
            let resultFrame = toView.characterImageView.frame
            
            let dummyViewScaledWidth = 110.0
            let dummyViewScaledHeight = (characterImageView.bounds.height * dummyViewScaledWidth) / characterImageView.bounds.width
            let dummyViewMiddleFrame = CGRect(x: (containerViewWidth - dummyViewScaledWidth) / 2,
                                              y: 250,
                                              width: dummyViewScaledWidth,
                                              height: dummyViewScaledHeight)
            
            await playDummyViewResize(characterImageView, frame: dummyViewMiddleFrame)
            await playWaitingViewsFadeIn()
            let response = try await animationClosure()
            await playWaitingViewsFadeOut()
            await playDummyViewResize(characterImageView, frame: resultFrame)
            
            starLottieView.removeFromSuperview()
            readyLabel.removeFromSuperview()
            toViewController.store.send(.updateResponse(response))
            toView.alpha = 1.0
            await toView.playAllComponentsFadeIn()
            
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
                                              duration: 1.0)],
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
                                              duration: 0.7),
                                        .init(view: readyLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.7)],
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
                                              duration: 0.7),
                                        .init(view: readyLabel,
                                              animationCase: .fadeOut,
                                              duration: 0.7)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
