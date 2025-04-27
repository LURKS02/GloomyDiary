//
//  CharacterButton.swift
//  GloomyDiary
//
//  Created by 디해 on 10/29/24.
//

import UIKit

final class CharacterButton: UIButton {
    
    private enum Metric {
        static let imagePadding: CGFloat = .deviceAdjustedHeight(20)
        static let imageSize: CGFloat = .deviceAdjustedHeight(120)
        static let topInset: CGFloat = 50
        static let horizontalInset: CGFloat = 50
        static let bottomInset: CGFloat = 37
    }
    
    let identifier: String
    
    private let character: CounselingCharacter
    
    init(character: CounselingCharacter) {
        self.character = character
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
    
    private func setupConfiguration(with character: CounselingCharacter) {
        let image = AppImage.Character.counselor(character, .normal).image
        self.setImage(image.resized(width: Metric.imageSize, height: Metric.imageSize), for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .top
        configuration.imagePadding = Metric.imagePadding
        
        var title = AttributedString(character.name)
        title.font = .온글잎_의연체.title
        title.foregroundColor = AppColor.Text.main.color
        configuration.attributedTitle = title
        configuration.titleAlignment = .center
        configuration.contentInsets = NSDirectionalEdgeInsets(top: Metric.topInset, leading: Metric.horizontalInset, bottom: Metric.bottomInset, trailing: Metric.horizontalInset)
        
        self.configuration = configuration
        
        let buttonStateHandler: UIButton.ConfigurationUpdateHandler = { button in
            guard var configuration = button.configuration else { return }
            switch button.state {
            case .normal:
                configuration.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
            case .selected:
                configuration.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
            default:
                return
            }
            
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
                self.configuration? = configuration
            }
        }
        
        self.configurationUpdateHandler = buttonStateHandler
    }
    
    func changeThemeIfNeeded() {
        let image = AppImage.Character.counselor(character, .normal).image
        self.setImage(image.resized(width: Metric.imageSize, height: Metric.imageSize), for: .normal)
        
        var title = AttributedString(character.name)
        title.font = .온글잎_의연체.title
        title.foregroundColor = AppColor.Text.main.color
        configuration?.attributedTitle = title
        
        let buttonStateHandler: UIButton.ConfigurationUpdateHandler = { button in
            guard var configuration = button.configuration else { return }
            switch button.state {
            case .normal:
                configuration.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
            case .selected:
                configuration.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
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
        
        AnimationGroup(
            animations: [
                Animation(
                    view: self,
                    animationCase: 
                        .transform( CGAffineTransform(scaleX: 0.95, y: 0.95)),
                    duration: 0.1
            )],
            mode: .parallel,
            loop: .once(completion: { })
        )
        .run()
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
