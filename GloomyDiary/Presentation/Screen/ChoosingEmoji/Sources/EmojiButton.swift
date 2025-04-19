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
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    init(emoji: Emoji) {
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
        configuration.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        self.configuration = configuration
    }
}

extension EmojiButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        var configuration = self.configuration
        configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color.withAlphaComponent(0.3)
        self.configuration = configuration
        
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        var configuration = self.configuration
        configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color.withAlphaComponent(0.3)
        
        self.configuration = configuration
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
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
