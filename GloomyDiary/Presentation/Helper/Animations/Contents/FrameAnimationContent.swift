//
//  FrameAnimationContent.swift
//  GloomyDiary
//
//  Created by 디해 on 1/24/25.
//

import UIKit

final class FrameAnimationContent: UIView, AnimationContent {
    let snapshot: UIView
    let initialFrame: CGRect
    let targetFrame: CGRect
    let duration: TimeInterval
    
    init?(
        _ component: UIView,
        initialFrame: CGRect,
        targetFrame: CGRect,
        duration: TimeInterval
    ) {
        guard let snapshot = component.snapshotView(afterScreenUpdates: false) else { return nil }
        self.snapshot = snapshot
        self.initialFrame = initialFrame
        self.targetFrame = targetFrame
        self.duration = duration
        snapshot.frame = initialFrame
        
        super.init(frame: .zero)
        
        addSubview(snapshot)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    func performAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: snapshot,
                                       animationCase: .frame(targetFrame),
                                       duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            )
            .run()
        }
    }
}
