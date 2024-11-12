//
//  ChoosingTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 9/17/24.
//

import UIKit
import Lottie

final class ChoosingTransition: NSObject {
    private let dummyView = UIImageView()
    
    private let starLottieView = LottieAnimationView(name: "stars").then {
        $0.frame = .init(x: 0, y: 0, width: 300, height: 135)
        $0.animationSpeed = 2.0
        $0.loopMode = .loop
        $0.contentMode = .scaleToFill
        $0.alpha = 0.0
        $0.play()
    }
    
    private let readyLabel = IntroduceLabel().then {
        $0.alpha = 0.0
    }
}

extension ChoosingTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 3.4
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) as? ChoosingCharacterView,
              let toView = transitionContext.view(forKey: .to) as? CounselingView,
              let fromViewController = transitionContext.viewController(forKey: .from) as? ChoosingCharacterViewController else { return }
        
        let chosenCharacter = fromViewController.store.character
        guard let selectedButton = fromViewController.contentView.allCharacterButtons.first(where: { $0.isSelected }),
              let selectedButtonImageView = selectedButton.imageView else { return }
        let selectedButtonImageFrame = selectedButtonImageView.convert(selectedButtonImageView.bounds, to: containerView)
        
        dummyView.image = UIImage(named: chosenCharacter.imageName)
        dummyView.frame = selectedButtonImageFrame
        readyLabel.text = chosenCharacter.counselReadyMessage
        readyLabel.sizeToFit()
        
        containerView.addSubview(dummyView)
        containerView.addSubview(starLottieView)
        containerView.addSubview(readyLabel)
        
        Task { @MainActor in
            await fromView.playFadeOutAllComponents()
            
            let containerViewWidth = containerView.bounds.width
            starLottieView.center = dummyView.center
            readyLabel.center = CGPoint(x: dummyView.center.x,
                                        y: dummyView.center.y + dummyView.frame.height / 2 + 50)
            
            toView.alpha = 0.0
            containerView.addSubview(toView)
            toView.layoutIfNeeded()
            let resultFrame = toView.characterImageView.frame
            
            await playWaitingViewsFadeIn()
            sleep(1)
            await playWaitingViewsFadeOut()
            await playDummyViewTo(frame: resultFrame)
            
            toView.alpha = 1.0
            await toView.showAllComponents()
            transitionContext.completeTransition(true)
        }
    }
}

private extension ChoosingTransition {
    @MainActor
    func playDummyViewTo(frame: CGRect) async {
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
