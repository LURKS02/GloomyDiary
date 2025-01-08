//
//  HistoryDetailTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 11/1/24.
//

import UIKit

final class HistoryDetailTransition: NSObject { }

extension HistoryDetailTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        1.0
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        if let fromViewController = transitionContext.viewController(forKey: .from) as? HistoryViewController,
           let toViewController = transitionContext.viewController(forKey: .to) as? HistoryDetailViewController {
            pushTransition(fromViewController: fromViewController, toViewController: toViewController, using: transitionContext)
            return
        }
        
        if let fromViewController = transitionContext.viewController(forKey: .from) as? HistoryDetailViewController,
           let toViewController = transitionContext.viewController(forKey: .to) as? HistoryViewController {
            popTransition(fromViewController: fromViewController, toViewController: toViewController, using: transitionContext)
            return
        }
    }
}


// MARK: - Push

extension HistoryDetailTransition {
    private func pushTransition(
        fromViewController: HistoryViewController,
        toViewController: HistoryDetailViewController,
        using transitionContext: any UIViewControllerContextTransitioning
    ) {
        let containerView = transitionContext.containerView
        let fromView = fromViewController.contentView
        let toView = toViewController.contentView
        
        containerView.addSubview(toView)
        toView.alpha = 0.0
        toView.frame = .init(x: 100, y: 0, width: fromView.bounds.width, height: fromView.bounds.height)
        
        Task { @MainActor in
            toViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            async let viewSlideAnimation: () = await showNextView(toView, frame: fromView.frame)
            await viewSlideAnimation
            toViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            
            transitionContext.completeTransition(true)
        }
    }
    
    @MainActor
    private func showNextView(_ view: UIView, frame: CGRect) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: view,
                                              animationCase: .fadeIn,
                                              duration: 0.4),
                                        .init(view: view,
                                              animationCase: .redraw(frame: frame),
                                              duration: 0.4)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}


// MARK: - Pop

extension HistoryDetailTransition {
    private func popTransition(
        fromViewController: HistoryDetailViewController,
        toViewController: HistoryViewController,
        using transitionContext: any UIViewControllerContextTransitioning
    ) {
        let containerView = transitionContext.containerView
        let fromView = fromViewController.contentView
        let toView = toViewController.contentView
        
        containerView.insertSubview(toView, at: 0)
        let fadingFrame: CGRect = .init(x: 100, y: 0, width: fromView.bounds.width, height: fromView.bounds.height)
        
        Task { @MainActor in
            await hideCurrentView(fromView, frame: fadingFrame)
            transitionContext.completeTransition(true)
        }
    }
    
    @MainActor
    private func hideCurrentView(_ view: UIView, frame: CGRect) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: view,
                                              animationCase: .fadeOut,
                                              duration: 0.4),
                                        .init(view: view,
                                              animationCase: .redraw(frame: frame),
                                              duration: 0.4)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
