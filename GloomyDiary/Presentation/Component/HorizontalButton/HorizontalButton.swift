//
//  Button.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

class HorizontalButton: UIButton {
    private enum Metric {
        static let buttonWidth: CGFloat = .deviceAdjustedHeight(180)
        static let buttonHeight: CGFloat = max(.deviceAdjustedHeight(56), 50)
        static let buttonCornerRadius: CGFloat = max(.deviceAdjustedHeight(28), 25)
    }
    
    private var originBackgroundColor: UIColor = AppColor.Component.horizontalButton.color
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    init() {
        super.init(frame: .zero)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.applyCornerRadius(Metric.buttonCornerRadius)
        self.titleLabel?.font = .온글잎_의연체.title
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(Metric.buttonHeight)
            make.width.equalTo(Metric.buttonWidth)
        }
    }
}

extension HorizontalButton {
    func setOriginBackgroundColor(with color: UIColor) {
        originBackgroundColor = color
        self.backgroundColor = color
    }
}

extension HorizontalButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        AnimationGroup(
            animations: [Animation(view: self,
                                   animationCase: .transform(CGAffineTransform(scaleX: 1.05, y: 1.05)),
                                   duration: 0.1)
            ],
            mode: .parallel,
            loop: .once(completion: nil))
        .run()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    
        AnimationGroup(
            animations: [Animation(view: self,
                                   animationCase: .transform(.identity),
                                   duration: 0.1)
            ],
            mode: .parallel,
            loop: .once(completion: nil))
        .run()
            
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        AnimationGroup(
            animations: [Animation(view: self,
                                   animationCase: .transform(.identity),
                                   duration: 0.1)],
            mode: .parallel,
            loop: .once(completion: {} ))
        .run()
    }
}
