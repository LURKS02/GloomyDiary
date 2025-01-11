//
//  TalkingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class TalkingView: BaseView {
    private enum Metric {
        static let verticalPadding: CGFloat = 18
        static let horizontalPadding: CGFloat = 23
        static let cornerRadius: CGFloat = 20
    }
    
    private let talkingLabel: UILabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .온글잎_의연체.title
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
            await updateFrame(text: text)
            await playTalkingLabelFadeIn()
        }
    }
    
    private func updateFrame(text: String) async {
        return await withCheckedContinuation { continuation in
            UIView.animate(withDuration: 0.15) {
                self.talkingLabel.text = text
                self.superview?.layoutIfNeeded()
            } completion: { _ in
                continuation.resume()
            }
        }
    }
}

extension TalkingView {
    @MainActor
    func playTalkingLabelFadeOut() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: talkingLabel,
                                              animationCase: .fadeOut,
                                              duration: 0.25)],
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
                                              duration: 0.25)],
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
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
