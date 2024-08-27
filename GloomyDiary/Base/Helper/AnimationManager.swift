//
//  AnimationManager.swift
//  GloomyDiary
//
//  Created by 디해 on 8/18/24.
//

import UIKit

final class AnimationManager {
    static let shared = AnimationManager()
    
    private init() { }
    
    func run(animations: [Animation], mode: Mode) {
        switch mode {
        case .infinite:
            runLoopAnimations(animations: animations)
        case .once:
            runAnimations(animations: animations)
        }
    }
    
    private func runLoopAnimations(animations: [Animation], index: Int = 0) {
        let animation = animations[index]
        let animator = UIViewPropertyAnimator(duration: animation.duration,
                                              curve: animation.curve,
                                              animations: animation.closure)
        
        animator.addCompletion { _ in
            animation.completion()
        }
        
        animator.addCompletion { [weak self] _ in
            let nextIndex = (index + 1) % animations.count
            self?.runLoopAnimations(animations: animations, index: nextIndex)
        }
        animator.startAnimation()
    }
    
    private func runAnimations(animations: [Animation], index: Int = 0) {
        let animation = animations[index]
        let animator = UIViewPropertyAnimator(duration: animation.duration,
                                              curve: animation.curve,
                                              animations: animation.closure)
        
        animator.addCompletion { _ in
            animation.completion()
        }
        
        animator.addCompletion { [weak self] _ in
            let nextIndex = (index + 1)
            if nextIndex < animations.count {
                self?.runAnimations(animations: animations, index: nextIndex)
            }
        }
        animator.startAnimation()
    }
}

extension AnimationManager {
    enum Mode {
        case infinite
        case once
    }
}
