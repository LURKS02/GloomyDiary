//
//  PasswordView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import UIKit

final class PasswordView: UIView {
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = AppColor.Background.letter.color
    }
    
    private func addSubviews() {
        
    }
    
    private func setupConstraints() {
        
    }
}

extension PasswordView {
    @MainActor
    func playAppearingAnimation(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 0,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(
                        view: self,
                        animationCase: .fadeIn,
                        duration: duration
                    ),
                    Animation(
                        view: self,
                        animationCase: .frame(targetFrame),
                        duration: duration
                    )
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            ).run()
        }
    }
    
    @MainActor
    func playDisappearingAnimation(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 100,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(
                        view: self,
                        animationCase: .fadeOut,
                        duration: duration
                    ),
                    Animation(
                        view: self,
                        animationCase: .frame(targetFrame),
                        duration: duration
                    )
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            ).run()
        }
    }
}
