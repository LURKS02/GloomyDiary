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
    
    func moveUpAndDown(_ view: UIView, value: Double, withDuration duration: TimeInterval = 1.0) {
        moveUpCycle(view, value: value, withDuration: duration)
    }
}

extension AnimationManager {
    private func moveUpCycle(_ view: UIView, value: Double, withDuration duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak view] in
            view?.transform = .identity.translatedBy(x: 0, y: -value)
        }
        animator.addCompletion { [weak self] position in
            if position == .end {
                self?.moveDownCycle(view, value: value, withDuration: duration)
            }
        }
        animator.startAnimation()
    }
    
    private func moveDownCycle(_ view: UIView, value: Double, withDuration duration: TimeInterval) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak view] in
            view?.transform = .identity.translatedBy(x: 0, y: value)
        }
        animator.addCompletion { [weak self] position in
            if position == .end {
                self?.moveUpCycle(view, value: value, withDuration: duration)
            }
        }
        animator.startAnimation()
    }
}
