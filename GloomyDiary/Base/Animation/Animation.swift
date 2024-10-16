//
//  Animation.swift
//  GloomyDiary
//
//  Created by 디해 on 8/19/24.
//

import UIKit

struct Animation {
    var view: UIView
    var animationCase: AnimationCase
    var duration: TimeInterval
    var curve: UIView.AnimationCurve = .easeInOut
}

extension Animation {
    var closure: () -> Void {
        switch animationCase {
        case .moveUp(value: let value):
            { [weak view] in
                view?.transform = .identity.translatedBy(x: 0, y: -value)
            }
        case .moveDown(let value):
            { [weak view] in
                view?.transform = .identity.translatedBy(x: 0, y: value)
            }
        case .fadeIn:
            { [weak view] in
                view?.alpha = 1.0
            }
        case .fadeOut:
            { [weak view] in
                view?.alpha = 0.0
            }
        case .fade(let value):
            { [weak view] in
                view?.alpha = value
            }
        case .redraw(let frame):
            { [weak view] in
                view?.frame = frame
            }
        case .transform(let transform):
            { [weak view] in
                view?.transform = transform
            }
        }
    }
}

enum AnimationCase {
    case moveUp(value: Double)
    case moveDown(value: Double)
    case fadeIn
    case fadeOut
    case fade(value: Double)
    case redraw(frame: CGRect)
    case transform(transform: CGAffineTransform)
}
