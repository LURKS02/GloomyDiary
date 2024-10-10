//
//  TalkingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class TalkingView: BaseView {
    private struct Metric {
        static let verticalPadding: CGFloat = 18
        static let horizontalPadding: CGFloat = 23
        static let cornerRadius: CGFloat = 20
    }
    
    private let talkingLabel: UILabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .무궁화.title
    }
    
    override func setup() {
        self.backgroundColor = .component(.darkPurple)
        self.layer.cornerRadius = Metric.cornerRadius
        self.layer.masksToBounds = true
    }
    
    override func addSubviews() {
        self.addSubview(talkingLabel)
    }
    
    override func setupConstraints() {
        talkingLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(Metric.verticalPadding)
            make.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
        }
    }
}

extension TalkingView {
    func update(text: String) {
        Task {
            await playTalkingLabelFadeOut()
            
            let oldBounds = self.bounds
            self.talkingLabel.text = text
            self.layoutIfNeeded()
            let newBounds = self.bounds
            
            let deltaX = oldBounds.width - newBounds.width
            let deltaY = oldBounds.height - newBounds.height
            
            self.frame = oldBounds
            
            await playFrameAnimation(CGRect(x: deltaX,
                                            y: deltaY,
                                            width: newBounds.width,
                                            height: newBounds.height))
            await playTalkingLabelFadeIn()
        }
    }
}

extension TalkingView {
    @MainActor
    func playTalkingLabelFadeOut() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: talkingLabel,
                                              animationCase: .fadeOut,
                                              duration: 0.3)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playTalkingLabelFadeIn() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: talkingLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.3)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFrameAnimation(_ frame: CGRect) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: self,
                                              animationCase: .redraw(frame: frame),
                                              duration: 0.3)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
