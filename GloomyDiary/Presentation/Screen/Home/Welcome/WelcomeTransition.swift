//
//  WelcomeTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 11/21/24.
//

import UIKit

final class WelcomeTransition: NSObject { }

extension WelcomeTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        4.5
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) as? WelcomeView,
              let toView = transitionContext.view(forKey: .to) as? GuideView,
              let fromViewController = transitionContext.viewController(forKey: .from) as? WelcomeViewController else { return }
        
        let ghostImageView = fromView.ghostImageView
        ghostImageView.translatesAutoresizingMaskIntoConstraints = true
        ghostImageView.snp.removeConstraints()
        
        toView.alpha = 0.0
        containerView.addSubview(ghostImageView)
        
        containerView.addSubview(toView)
        fromView.stopGhostBouncing()
        
        toView.layoutIfNeeded()
        let destinationFrame = toView.ghostImageView.frame
        
        Task { @MainActor in
            async let fadeOutAnimation: () = await fromView.playFadeOutAllComponents()
            async let frameAnimation: () = await playFrame(ghostImageView, to: destinationFrame)
            let _ = await (fadeOutAnimation, frameAnimation)
            
            toView.hideAllLabels()
            toView.alpha = 1.0
            await toView.runLabelAnimation(index: 0)
            
            transitionContext.completeTransition(true)
        }
    }
}

private extension WelcomeTransition {
    @MainActor
    func playFrame(_ view: UIView, to frame: CGRect) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: view, animationCase: .redraw(frame: frame),
                                              duration: 1.0)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
