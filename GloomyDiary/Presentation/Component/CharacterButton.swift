//
//  CharacterChooseView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class CharacterButton: UIButton {
    
    // MARK: - Metric
    
    private struct Metric {
        static let imageSize: CGFloat = 58
        static let imageTopPadding: CGFloat = 18
        static let imageHorizontalPadding: CGFloat = 25
        static let imageBottomPadding: CGFloat = 60
        static let buttonBorderWidth = 2.0
        static let cornerRadius: CGFloat = 20
        static let imageNamePadding: CGFloat = 9
        static let nameBottomPadding: CGFloat = 28
        static let buttonWidth: CGFloat = 108
        static let buttonHeight: CGFloat = 136
    }
    
    
    // MARK: - Properties

    let identifier: String
    
    var characterFrame: CGRect? {
        self.imageView?.frame
    }
    
    
    // MARK: - Initialize
    
    init(character: Character) {
        self.identifier = character.identifier
        
        super.init(frame: .zero)
        
        setup()
        setupConstraints()
        setupConfiguration(with: character)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        self.layer.borderWidth = Metric.buttonBorderWidth
        self.layer.cornerRadius = Metric.cornerRadius
        self.layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.equalTo(Metric.buttonWidth)
            make.height.equalTo(Metric.buttonHeight)
        }
    }
    
    private func setupConfiguration(with character: Character) {
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .top
        configuration.imagePadding = Metric.imageNamePadding
        configuration.background.backgroundColor = .component(.buttonPurple)
        
        self.configurationUpdateHandler = { button in
            if button.isSelected {
                self.layer.borderColor = UIColor.component(.lightGray).cgColor
            } else {
                self.layer.borderColor = UIColor.component(.fogGray).cgColor
            }
        }
        
        self.configuration = configuration
        updateConfiguration(title: character.name)
        updateConfiguration(imageName: character.imageName)
    }
    
    private func updateConfiguration(title: String) {
        var title = AttributedString(title)
        title.font = .무궁화.title
        title.foregroundColor = .text(.highlight)
        self.configuration?.attributedTitle = title
    }
    
    private func updateConfiguration(imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        let resizedImage = image.resized(width: Metric.imageSize, height: Metric.imageSize)
        self.configuration?.image = resizedImage
    }
}
