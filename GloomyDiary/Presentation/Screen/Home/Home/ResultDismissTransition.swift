//
//  ResultDismissTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 10/14/24.
//

import UIKit

final class ResultDismissTransition: NSObject {
    
}

extension ResultDismissTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let toView = toViewController?.view
        let originSuperview = toView?.superview
        
        let dismissable = fromViewController?.dismissable
        let dismissedAppearable = toViewController?.dismissedAppearable
        
        guard let toView, let dismissable, let dismissedAppearable else { return }
        
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        Task { @MainActor in
            await dismissable.playDismissingAnimation()
            toView.alpha = 1.0
            await dismissedAppearable.playAppearingAnimation()
            originSuperview?.addSubview(toView)
            
            transitionContext.completeTransition(true)
        }
    }
}

private extension UIViewController {
    var dismissable: Dismissable? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController as? Dismissable
        } else {
            return self as? Dismissable
        }
    }
    
    var dismissedAppearable: DismissedAppearable? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController as? DismissedAppearable
        } else {
            return self as? DismissedAppearable
        }
    }
}
