//
//  HomePresentTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import UIKit

final class PresentingTransition: NSObject { }

extension PresentingTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let toView = toViewController?.view
        
        let presentingDisappearable = fromViewController?.presentingDisappearable
        let presentable = toViewController?.presentable
        
        guard let toView, let presentingDisappearable, let presentable else { return }
        
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        Task { @MainActor in
            await presentingDisappearable.playDisappearingAnimation()
            toView.alpha = 1.0
            await presentable.playAppearingAnimation()
            
            transitionContext.completeTransition(true)
        }
    }
}

private extension UIViewController {
    var presentingDisappearable: PresentingDisappearable? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController as? PresentingDisappearable
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController as? PresentingDisappearable
        } else {
            return self as? PresentingDisappearable
        }
    }
    
    var presentable: Presentable? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController as? Presentable
        } else {
            return self as? Presentable
        }
    }
}
