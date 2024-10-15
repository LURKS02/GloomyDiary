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
    
    private let dummyView = UIImageView()
    
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
              let fromViewController = transitionContext.viewController(forKey: .from) as? CounselingViewController else { return }
        
        let character = fromViewController.store.character
        
        containerView.addSubview(fromView)
        fromView.addSubview(dummyView)
        
        Task { @MainActor in
            dummyView.image = UIImage(named: character.imageName)
            dummyView.frame = fromViewController.contentView.characterImageView.frame
            readyLabel.text = character.counselWaitingMessage
            readyLabel.sizeToFit()
            
            await fromView.removeAllComponents()
            
            containerView.addSubview(dummyView)
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
            let dummyViewScaledHeight = (dummyView.bounds.height * dummyViewScaledWidth) / dummyView.bounds.width
            let dummyViewMiddleFrame = CGRect(x: (containerViewWidth - dummyViewScaledWidth) / 2,
                                              y: 250,
                                              width: dummyViewScaledWidth,
                                              height: dummyViewScaledHeight)
            
            await playDummyViewResize(frame: dummyViewMiddleFrame)
            await playWaitingViewsFadeIn()
            let response = try await animationClosure()
            await playWaitingViewsFadeOut()
            await playDummyViewResize(frame: resultFrame)
            
            dummyView.removeFromSuperview()
            starLottieView.removeFromSuperview()
            readyLabel.removeFromSuperview()
            toView.counselLetterView.letterTextView.text = response
            toView.alpha = 1.0
            await toView.playAllComponentsFadeIn()
            transitionContext.completeTransition(true)
        }
    }
}

private extension CounselTransition {
    @MainActor
    func playDummyViewResize(frame: CGRect) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: dummyView,
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
