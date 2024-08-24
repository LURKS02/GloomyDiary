//
//  Animation.swift
//  GloomyDiary
//
//  Created by 디해 on 8/19/24.
//

import UIKit

struct Animation {
    var closure: () -> Void
    var duration: TimeInterval
    var curve: UIView.AnimationCurve
    
    init(view: UIView, type: AnimationType, duration: TimeInterval, curve: UIView.AnimationCurve) {
        switch type {
        case .moveUp(let value):
            self.closure = { [weak view] in
                view?.transform = .identity.translatedBy(x: 0, y: -value)
            }
        case .moveDown(let value):
            self.closure = { [weak view] in
                view?.transform = .identity.translatedBy(x: 0, y: value)
            }
        case .fadeInOut(let value):
            self.closure = { [weak view] in
                view?.alpha = value
            }
        case .expandInOut(let x, let y, let width, let height):
            self.closure = { [weak view] in
                view?.frame = CGRect(x: x, y: y, width: width, height: height)
            }
        }
        
        self.duration = duration
        self.curve = curve
    }
}

extension Animation {
    enum AnimationType {
        case moveUp(value: Double)
        case moveDown(value: Double)
        case fadeInOut(value: TimeInterval)
        case expandInOut(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
    }
}
