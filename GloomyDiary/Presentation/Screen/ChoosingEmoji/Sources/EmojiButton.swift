//
//  EmojiButton.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class EmojiButton: UIButton {
    
    private enum Metric {
        static let imagePadding: CGFloat = 5
        static let imageSize: CGFloat = .deviceAdjustedHeight(40)
        static let cornerRadius: CGFloat = .deviceAdjustedHeight(20)
    }
    
    let identifier: String
    
    private let emoji: Emoji
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    private var isPressed: Bool = false {
        didSet {
            if isPressed {
                configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color.withAlphaComponent(0.3)
            } else {
                if !isPicked {
                    configuration?.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
                }
            }
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            if isPicked {
                configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
            } else {
                configuration?.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
            }
        }
    }
    
    init(emoji: Emoji) {
        self.emoji = emoji
        self.identifier = emoji.identifier
        super.init(frame: .zero)
        
        setupConfiguration(with: emoji)
        applyCornerRadius(Metric.cornerRadius)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConfiguration(with emoji: Emoji) {
        let image = AppImage.Component.emoji(emoji).image
        self.setImage(image.resized(width: Metric.imageSize, height: Metric.imageSize), for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .top
        configuration.imagePadding = Metric.imagePadding
        
        var title = AttributedString(emoji.description)
        title.font = .온글잎_의연체.body
        title.foregroundColor = AppColor.Text.main.color
        configuration.attributedTitle = title
        configuration.titleAlignment = .center
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        configuration.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
        
        self.configuration = configuration
    }
    
    func changeThemeIfNeeded() {
        let image = AppImage.Component.emoji(emoji).image
        self.setImage(image.resized(width: Metric.imageSize, height: Metric.imageSize), for: .normal)
        
        guard var configuration = self.configuration else { return }
        var title = AttributedString(emoji.description)
        title.font = .온글잎_의연체.body
        title.foregroundColor = AppColor.Text.main.color
        configuration.attributedTitle = title
        
        if isPressed {
            configuration.background.backgroundColor = AppColor.Component.selectedSelectionButton.color.withAlphaComponent(0.3)
        } else if isPicked {
            configuration.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
        } else {
            configuration.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
        }
        
        self.configuration = configuration
    }
}

extension EmojiButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        isPressed = true
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        AnimationGroup(
            animations: [
                Animation(view: self,
                          animationCase: .transform( CGAffineTransform(scaleX: 0.95, y: 0.95)),
                          duration: 0.1)],
            mode: .parallel,
            loop: .once(completion: { })
        )
        .run()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if bounds.contains(location) {
            isPicked = true
        }
        
        isPressed = false
        
        AnimationGroup(
            animations: [
                Animation(view: self,
                          animationCase: .transform( .identity),
                          duration: 0.1)],
            mode: .parallel,
            loop: .once(completion: {} )
        )
        .run()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        isPressed = false
        
        AnimationGroup(
            animations: [
                Animation(view: self,
                          animationCase: .transform( .identity),
                          duration: 0.1)],
            mode: .parallel,
            loop: .once(completion: {})
        )
        .run()
    }
}
