//
//  GuideOverTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 11/22/24.
//

import UIKit

final class GuideOverTransition: NSObject { }

extension GuideOverTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        2.0
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) as? GuideView,
              let toView = transitionContext.view(forKey: .to) as? StartCounselingView else { return }
        
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        Task { @MainActor in
            await fromView.hideAllComponents()
            toView.hideAllComponents()
            toView.moonImageView.alpha = 0.0
            toView.alpha = 1.0
            
            toView.moonImageView.transform = .identity.translatedBy(x: 0, y: .verticalValue(35))
            await withCheckedContinuation { continuation in
                AnimationGroup(animations: [.init(view: toView.moonImageView,
                                                  animationCase: .fadeIn,
                                                  duration: 0.5)],
                               mode: .parallel,
                               loop: .once(completion: { continuation.resume() }))
                .run()
            }
            await toView.playFadeInFirstPart()
            await toView.playFadeInSecondPart()
            
            transitionContext.completeTransition(true)
        }
    }
}
