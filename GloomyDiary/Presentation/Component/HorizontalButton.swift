//
//  Button.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class HorizontalButton: UIButton {
    private struct Metric {
        static let buttonWidth: CGFloat = 180
        static let buttonHeight: CGFloat = 56
        static let buttonCornerRadius: CGFloat = 28
    }
    
    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.setTitleColor(.text(.highlight), for: .normal)
        self.setTitleColor(.text(.buttonDisabled), for: .disabled)
        self.backgroundColor = .component(.buttonPurple)
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
    private func updateAppearance() {
        if isEnabled {
            self.backgroundColor = .component(.buttonPurple)
        } else {
            self.backgroundColor = .component(.buttonDisabledPurple)
        }
    }
}

extension HorizontalButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: CGAffineTransform(scaleX: 0.95, y: 0.95)),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: {}))
        .run()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: {} ))
        .run()
            
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: {} ))
        .run()
    }
}
