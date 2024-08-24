//
//  GhostView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import Foundation

final class GhostView: ImageView {
    init(size: CGFloat) {
        super.init(imageName: "ghost", size: size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
