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
        guard let fromNavigationController = transitionContext.viewController(forKey: .from) as? UINavigationController,
              let fromViewController = fromNavigationController.topViewController as? ResultViewController else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) as? HomeViewController,
              let tabBarController = toViewController.tabBarController as? TabBarController else { return }

        guard let fromView = fromViewController.view as? ResultView else { return }
        guard let toView = toViewController.view as? HomeView else {
            return }
        
        containerView.addSubview(fromView)
        let originSuperview = toView.superview
        containerView.addSubview(toView)
        toView.alpha = 0.0
        toView.hideAllComponents()
        
        Task { @MainActor in
            await fromView.playAllComponentsFadeOut()
            toView.alpha = 1.0
            async let playAllComponentsFadeIn: () = toView.playAllComponentsFadeIn()
            async let playTabBarFadeIn: () = tabBarController.playFadeInTabBar()
            let _ = await (playAllComponentsFadeIn, playTabBarFadeIn)
            fromView.removeFromSuperview()
            
            transitionContext.completeTransition(true)
            originSuperview?.addSubview(toView)
        }
    }
}
