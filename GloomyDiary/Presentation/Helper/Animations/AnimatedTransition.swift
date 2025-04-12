//
//  AnimatedTransition.swift
//  GloomyDiary
//
//  Created by 디해 on 1/24/25.
//

import UIKit

final class AnimatedTransition: NSObject {
    private let fromDuration: TimeInterval
    private let contentDuration: TimeInterval
    private let toDuration: TimeInterval
    private let timing: Timing
    private let transitionContentType: TransitionContentType
    
    init(
        fromDuration: TimeInterval = 1.0,
        contentDuration: TimeInterval = 0.0,
        toDuration: TimeInterval = 1.0,
        timing: Timing = .serial,
        transitionContentType: TransitionContentType
    ) {
        self.fromDuration = fromDuration
        self.contentDuration = contentDuration
        self.toDuration = toDuration
        self.timing = timing
        self.transitionContentType = transitionContentType
        
        super.init()
    }
}

extension AnimatedTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        switch timing {
        case .withFrom:
            max(fromDuration, contentDuration) + toDuration
        case .serial:
            fromDuration + contentDuration + toDuration
        case .withTo:
            fromDuration + max(contentDuration, toDuration)
        case .parallel:
            max(fromDuration, contentDuration, toDuration)
        }
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let fromView = fromViewController?.viewIfLoaded
        let toView = toViewController?.viewIfLoaded
        
        let fromTransitionable = fromViewController?.fromTransitionable()
        let toTransitionable = toViewController?.toTransitionable()
        
        let originSuperview = toView?.superview
        
        if let fromView {
            containerView.addSubview(fromView)
        }
        
        if let toView {
            toView.layoutIfNeeded()
            toView.alpha = 0.0
            containerView.addSubview(toView)
        }
        
        var transitionContentView: AnimationContent?
        var fromComponent: UIView?
        var toComponent: UIView?
        
        switch transitionContentType {
        case .normalTransition:
            transitionContentView = nil
            
        case .switchedHierarchyTransition:
            if let fromView {
                fromView.removeFromSuperview()
                containerView.addSubview(fromView)
            }
            
        case .frameTransition:
            guard let fromComp = fromTransitionable?.fromTransitionComponent,
                  let toComp = toTransitionable?.toTransitionComponent else { return }
            
            fromComponent = fromComp
            toComponent = toComp
            
            fromComponent?.isHidden = true
            toComponent?.isHidden = true
            
            let initialFrame = containerView.convert(fromComp.frame, from: fromComp.superview)
            let finalFrame = containerView.convert(toComp.frame, from: toComp.superview)
            
            guard let transitionView = FrameAnimationContent(
                fromComp,
                initialFrame: initialFrame,
                targetFrame: finalFrame,
                duration: contentDuration
            ) else { return }
            
            transitionContentView = transitionView
            
            containerView.addSubview(transitionView)
            transitionView.frame = containerView.bounds
            
        case .frameTransitionWithLottie(let character):
            guard let fromComp = fromTransitionable?.fromTransitionComponent,
                  let toComp = toTransitionable?.toTransitionComponent else { return }
            
            fromComponent = fromComp
            toComponent = toComp
            
            fromComponent?.isHidden = true
            toComponent?.isHidden = true
            
            let initialFrame = containerView.convert(fromComp.frame, from: fromComp.superview)
            let finalFrame = containerView.convert(toComp.frame, from: toComp.superview)
            
            guard let transitionView = FrameAnimationContentWithLottie(
                fromComp,
                initialFrame: initialFrame,
                targetFrame: finalFrame,
                duration: contentDuration,
                character: character
            ) else { return }
            
            transitionContentView = transitionView
            
            containerView.addSubview(transitionView)
            transitionView.frame = containerView.bounds
            
        case .frameTransitionWithClosure(let character, let closure):
            guard let fromComp = fromTransitionable?.fromTransitionComponent else { return }
            
            fromComponent = fromComp
            
            guard let toViewController = toViewController as? ResultViewController else { return }
            toViewController.view.layoutIfNeeded()
            
            let initialFrame = containerView.convert(fromComp.frame, from: fromComp.superview)
            
            guard let transitionView = FrameAnimationContentWithClosure(
                fromComp,
                initialFrame: initialFrame,
                successFrame: .zero,
                failureFrame: .zero,
                duration: contentDuration,
                character: character,
                perform: closure,
                completion: { response in
                    if let response {
                        toViewController.hasValidResult = true
                        toViewController.store.send(.view(.updateResponse(response)))
                        toViewController.view.layoutIfNeeded()
                        
                        guard let concreteView = toViewController.view as? ResultView else { return .zero }
                        toComponent = concreteView.validResultView.characterImageView
                        return containerView.convert(concreteView.validResultView.characterImageView.frame, from: concreteView.validResultView)
                    } else {
                        toViewController.hasValidResult = false
                        toViewController.view.layoutIfNeeded()
                        
                        guard let concreteView = toViewController.view as? ResultView else { return .zero}
                        toComponent = concreteView.errorResultView.characterImageView
                        return containerView.convert(concreteView.errorResultView.characterImageView.frame, from: concreteView.errorResultView)
                    }
                }
            ) else { return }
            
            transitionContentView = transitionView
            
            containerView.addSubview(transitionView)
            transitionView.frame = containerView.bounds
        }
        
        Task { @MainActor in
            switch timing {
            case .withFrom:
                async let fromAnimation: ()? = await fromTransitionable?.prepareTransition(duration: fromDuration)
                async let contentAnimation: ()? = await transitionContentView?.performAnimation()
                let _ = await (fromAnimation, contentAnimation)
                toView?.alpha = 1.0
                await toTransitionable?.completeTransition(duration: toDuration)
                
            case .serial:
                await fromTransitionable?.prepareTransition(duration: fromDuration)
                await transitionContentView?.performAnimation()
                toView?.alpha = 1.0
                await toTransitionable?.completeTransition(duration: toDuration)
                
            case .withTo:
                await fromTransitionable?.prepareTransition(duration: fromDuration)
                toView?.alpha = 1.0
                async let contentAnimation: ()? = await transitionContentView?.performAnimation()
                async let toAnimation: ()? = await toTransitionable?.completeTransition(duration: toDuration)
                let _ = await (contentAnimation, toAnimation)
                
            case .parallel:
                toView?.alpha = 1.0
                async let fromAnimation: ()? = await fromTransitionable?.prepareTransition(duration: fromDuration)
                async let contentAnimation: ()? = await transitionContentView?.performAnimation()
                async let toAnimation: ()? = await toTransitionable?.completeTransition(duration: toDuration)
                
                let _ = await (fromAnimation, contentAnimation, toAnimation)
            }
                
            if let toView {
                originSuperview?.addSubview(toView)
            }
            
            fromComponent?.isHidden = false
            toComponent?.isHidden = false
            transitionContentView?.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
    }
}
