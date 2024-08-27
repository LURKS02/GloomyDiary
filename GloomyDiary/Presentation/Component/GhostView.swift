//
//  GhostView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import Foundation

final class GhostView: ImageView {
    
    func startLoopMoving() {
        AnimationManager.shared.run(animations: [.init(view: self,
                                                       type: .moveUp(value: 5),
                                                       duration: 1.0,
                                                       curve: .easeInOut),
                                                 .init(view: self,
                                                       type: .moveDown(value: 5),
                                                       duration: 1.0,
                                                       curve: .easeInOut)],
                                    mode: .infinite)
    }
}
