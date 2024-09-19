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
    var completion: () -> Void
    
    init(view: UIView?, type: AnimationType, duration: TimeInterval, curve: UIView.AnimationCurve = .easeInOut, completion: @escaping () -> Void = {}) {
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
        case .expandInOut(let frame):
            self.closure = { [weak view] in
                view?.frame = frame
            }
        }
        
        self.duration = duration
        self.curve = curve
        self.completion = completion
    }
}

extension Animation {
    enum AnimationType {
        case moveUp(value: Double)
        case moveDown(value: Double)
        case fadeInOut(value: CGFloat)
        case expandInOut(frame: CGRect)
    }
}
