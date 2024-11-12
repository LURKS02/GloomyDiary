//
//  EmojiButton.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class EmojiButton: UIButton {
    
    private struct Metric {
        static let imagePadding: CGFloat = 5
    }
    
    let identifier: String
    
    init(emoji: EmojiDTO) {
        self.identifier = emoji.identifier
        super.init(frame: .zero)
        
        setupConfiguration(with: emoji)
        applyCornerRadius(20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConfiguration(with emoji: EmojiDTO) {
        self.setImage(UIImage(named: emoji.imageName)?.resized(width: 40, height: 40), for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .top
        configuration.imagePadding = Metric.imagePadding
        
        var title = AttributedString(emoji.description)
        title.font = .무궁화.body
        title.foregroundColor = .text(.highlight)
        configuration.attributedTitle = title
        configuration.titleAlignment = .center
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        self.configuration = configuration
        
        let buttonStateHandler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case .normal:
                button.configuration?.background.backgroundColor = .component(.buttonPurple)
            case .selected:
                button.configuration?.background.backgroundColor = .component(.buttonSelectedBlue)
            default:
                return
            }
        }
        self.configurationUpdateHandler = buttonStateHandler
    }
}

extension EmojiButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: CGAffineTransform(scaleX: 0.95, y: 0.95)),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: { }))
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
                            loop: .once(completion: {}))
        .run()
    }
}
