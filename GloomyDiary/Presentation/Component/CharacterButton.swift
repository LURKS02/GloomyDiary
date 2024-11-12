//
//  CharacterButton.swift
//  GloomyDiary
//
//  Created by 디해 on 10/29/24.
//

import UIKit

final class CharacterButton: UIButton {
    
    private struct Metric {
        static let imagePadding: CGFloat = 20
    }
    
    let identifier: String
    
    init(character: CharacterDTO) {
        self.identifier = character.identifier
        super.init(frame: .zero)
        
        setupConfiguration(with: character)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyCornerRadius(20)
    }
    
    private func setupConfiguration(with character: CharacterDTO) {
        self.setImage(UIImage(named: character.imageName)?.resized(width: 120, height: 120), for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .top
        configuration.imagePadding = Metric.imagePadding
        
        var title = AttributedString(character.name)
        title.font = .무궁화.title
        title.foregroundColor = .text(.highlight)
        configuration.attributedTitle = title
        configuration.titleAlignment = .center
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 50, leading: 50, bottom: 37, trailing: 50)
        
        self.configuration = configuration
        
        let buttonStateHandler: UIButton.ConfigurationUpdateHandler = { button in
            guard var configuration = button.configuration else { return }
            switch button.state {
            case .normal:
                configuration.background.backgroundColor = .component(.buttonPurple)
            case .selected:
                configuration.background.backgroundColor = .component(.buttonSelectedBlue)
            default:
                return
            }
            
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
                self.configuration? = configuration
            }
        }
        
        self.configurationUpdateHandler = buttonStateHandler
    }
}

extension CharacterButton {
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
