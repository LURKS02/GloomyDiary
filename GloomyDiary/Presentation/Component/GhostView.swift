//
//  GhostView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import Foundation
import UIKit

final class GhostView: ImageView {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    @MainActor
    func playBounce() {
        AnimationGroup(animations: [.init(view: self,
                                          animationCase: .moveUp(value: 5),
                                          duration: 1.0),
                                    .init(view: self,
                                          animationCase: .moveDown(value: 5),
                                          duration: 1.0)],
                       mode: .serial,
                       loop: .infinite)
        .run()
    }
    
    @MainActor
    func playFadeIn() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: self,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}

extension GhostView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}
