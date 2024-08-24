//
//  TalkingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class TalkingView: BaseView {
    private struct Matric {
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
        self.layer.cornerRadius = Matric.cornerRadius
        self.layer.masksToBounds = true
    }
    
    override func addSubviews() {
        self.addSubview(talkingLabel)
    }
    
    override func setupConstraints() {
        talkingLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(Matric.verticalPadding)
            make.horizontalEdges.equalToSuperview().inset(Matric.horizontalPadding)
        }
    }
}

extension TalkingView {
    func update(text: String) {
//        let currentFrame = self.bounds
//        var newFrame: CGRect = CGRectZero
//    
//        AnimationManager.shared.run(animations: [ .init(view: talkingLabel,
//                                                        type: .fadeInOut(value: 0.0),
//                                                        duration: 0.3,
//                                                        curve: .easeInOut,
//                                                        completion: { [weak self] in
//            self?.talkingLabel.text = text
//            self?.layoutIfNeeded()
//            newFrame = self?.bounds ?? CGRectZero
//            self?.frame = currentFrame
//        }),
//                                                  .init(view: self, 
//                                                        type: .expandInOut(x: currentFrame.width - newFrame.width,
//                                                                           y: currentFrame.height - newFrame.height,
//                                                                           width: newFrame.width,
//                                                                           height: newFrame.height),
//                                                        duration: 0.3,
//                                                        curve: .easeInOut),
//                                                  .init(view: talkingLabel,
//                                                        type: .fadeInOut(value: 1.0),
//                                                        duration: 0.3,
//                                                        curve: .easeInOut)
//        ], mode: .once)
//        
        UIView.animate(withDuration: 0.3) {
            self.talkingLabel.alpha = 0.0
        } completion: { _ in
            let oldBounds = self.bounds
            self.talkingLabel.text = text
            self.layoutIfNeeded()
            let newBounds = self.bounds
            
            let deltaX = oldBounds.width - newBounds.width
            let deltaY = oldBounds.height - newBounds.height
            
            self.frame = oldBounds
            
            UIView.animate(withDuration: 0.3, animations: {
                self.frame = CGRect(x: deltaX, y: deltaY, width: newBounds.width, height: newBounds.height)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    self.talkingLabel.alpha = 1.0
                }
            }
        }
    }
}
