//
//  ResultBackTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 12/2/24.
//

import UIKit

final class ResultBackTransition: NSObject { }

extension ResultBackTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        1.0
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) as? ResultView,
              let toView = transitionContext.view(forKey: .to) as? CounselingView else { return }
        
        containerView.addSubview(toView)
        toView.alpha = 0.0
        toView.hideAllComponents()
        
        Task { @MainActor in
            await fromView.errorResultView.playAllComponentsFadeOut()
            toView.alpha = 1.0
            await toView.showAllComponents()
            transitionContext.completeTransition(true)
        }
    }
}
