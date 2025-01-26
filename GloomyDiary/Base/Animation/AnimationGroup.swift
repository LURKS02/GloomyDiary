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
        switch mode {
        case .serial:
            serializeAnimations(loop, animations: animations)
        case .parallel:
            parallelizeAnimations(loop, animations: animations)
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
    func serializeAnimations(_ loop: Loop, animations: [Animation]) {
        let animators = animations.map { UIViewPropertyAnimator(duration: $0.duration,
                                                                curve: $0.curve,
                                                                animations: $0.closure) }
        switch loop {
        case .once(let completion):
            startSequentialAnimators(with: animators, completion: completion ?? {})
        case .infinite:
            loopAnimators(with: animations)
        }
    }
    
    func parallelizeAnimations(_ loop: Loop, animations: [Animation]) {
        let animators = animations.map { UIViewPropertyAnimator(duration: $0.duration,
                                                                curve: $0.curve,
                                                                animations: $0.closure) }
        switch loop {
        case .once(let completion):
            startParallelAnimators(with: animators, completion: completion ?? {})
        case .infinite:
            loopAnimators(with: animations)
        }
    }
    
    func loopAnimators(with animations: [Animation], at index: Int = 0) {
        guard !animations.isEmpty else { return }
        
        let currentAnimation = animations[index]
        let currentAnimator = UIViewPropertyAnimator(duration: currentAnimation.duration,
                                                     curve: currentAnimation.curve,
                                                     animations: currentAnimation.closure)
        currentAnimator.startAnimation()
        
        currentAnimator.addCompletion { _ in
            let nextIndex = (index + 1) % animations.count
            self.loopAnimators(with: animations, at: nextIndex)
        }
    }
    
    func startSequentialAnimators(
        with animators: [UIViewPropertyAnimator],
        completion: @escaping () -> Void
    ) {
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
    
    func startParallelAnimators(
        with animators: [UIViewPropertyAnimator],
        completion: @escaping () -> Void
    ) {
        guard let longestAnimator = animators.max(by: { $0.duration > $1.duration }) else {
            completion()
            return
        }
        
        animators.forEach { $0.startAnimation() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + longestAnimator.duration) {
            completion()
        }
    }
}
