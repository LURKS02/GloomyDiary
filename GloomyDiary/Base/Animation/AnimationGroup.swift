//
//  AnimationGroup.swift
//  GloomyDiary
//
//  Created by 디해 on 10/3/24.
//

import UIKit

struct AnimationGroup {
    let animations: [Animation]
    let mode: Mode
    let loop: Loop
    
    func run() {
        let animators = animations.map { UIViewPropertyAnimator(duration: $0.duration,
                                   curve: $0.curve,
                                   animations: $0.closure)
        }
        
        switch mode {
        case .serial:
            serializeAnimations(loop, animators: animators)
        case .parallel:
            parallelizeAnimations(loop, animators: animators)
        }
    }
}

extension AnimationGroup {
    enum Mode {
        case serial
        case parallel
    }
    
    enum Loop {
        case once(completion: (() -> Void)?)
        case infinite
    }
}

private extension AnimationGroup {
    func serializeAnimations(_ loop: Loop, animators: [UIViewPropertyAnimator]) {
        switch loop {
        case .once(let completion):
            startSequentialAnimators(with: animators, completion: completion ?? {})
        case .infinite:
            loopAnimators(with: animators)
        }
    }
    
    func parallelizeAnimations(_ loop: Loop, animators: [UIViewPropertyAnimator]) {
        switch loop {
        case .once(let completion):
            startParallelAnimators(with: animators, completion: completion ?? {})
        case .infinite:
            animators.forEach { loopAnimators(with: [$0] )}
        }
    }
    
    func loopAnimators(with animators: [UIViewPropertyAnimator]) {
        guard !animators.isEmpty else { return }
        
        for (index, animator) in animators.enumerated() {
            animator.addCompletion { _ in
                let nextIndex = (index + 1) % animators.count
                animators[nextIndex].startAnimation()
            }
        }
        
        animators.first?.startAnimation()
    }
    
    func startSequentialAnimators(with animators: [UIViewPropertyAnimator], completion: @escaping () -> Void) {
        guard !animators.isEmpty else { return }
        
        for (index, animator) in animators.enumerated() {
            animator.addCompletion { _ in
                let nextIndex = index + 1
                if nextIndex < animators.count {
                    animators[nextIndex].startAnimation()
                } else {
                    completion()
                }
            }
        }
        
        animators.first?.startAnimation()
    }
    
    func startParallelAnimators(with animators: [UIViewPropertyAnimator], completion: @escaping () -> Void) {
        guard let longestAnimator = animators.max(by: { $0.duration < $1.duration }) else {
            completion()
            return
        }
        
        longestAnimator.addCompletion { _ in
            completion()
        }
        
        animators.forEach { $0.startAnimation() }
    }
}
