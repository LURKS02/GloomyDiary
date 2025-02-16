//
//  TabSwitchingTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 10/26/24.
//

import UIKit

protocol ToTabSwitchAnimatable: UIViewController {
    func playTabAppearingAnimation() async
}

protocol FromTabSwitchAnimatable: UIViewController {
    func playTabDisappearingAnimation() async
}

final class TabSwitchingTransition: NSObject { }

extension TabSwitchingTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)

        let toView = toViewController?.view
        
        let toTabSwitchable = toViewController?.toTabSwitchable
        let fromTabSwitchable = fromViewController?.fromTabSwitchable
        
        guard let toView, let toTabSwitchable, let fromTabSwitchable else { return }
        
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        Task { @MainActor in
            await fromTabSwitchable.playTabDisappearingAnimation()
            toView.alpha = 1.0
            await toTabSwitchable.playTabAppearingAnimation()
            
            transitionContext.completeTransition(true)
        }
    }
}

private extension UIViewController {
    var toTabSwitchable: ToTabSwitchAnimatable? {
        if let naivgationController = self as? UINavigationController {
            return naivgationController.topViewController as? ToTabSwitchAnimatable
        } else {
            return self as? ToTabSwitchAnimatable
        }
    }
    
    var fromTabSwitchable: FromTabSwitchAnimatable? {
        if let naivgationController = self as? UINavigationController {
            return naivgationController.topViewController as? FromTabSwitchAnimatable
        } else {
            return self as? FromTabSwitchAnimatable
        }
    }
}
