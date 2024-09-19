//
//  CharacterChooseView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class CharacterButton: UIButton {
    private struct Matric {
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
    
    init(character: Character) {
        super.init(frame: .zero)
        
        setup()
        setupConstraints()
        setupConfiguration()
        updateConfiguration(title: character.name)
        updateConfiguration(imageName: character.imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.layer.borderWidth = Matric.buttonBorderWidth
        self.layer.cornerRadius = Matric.cornerRadius
        self.layer.masksToBounds = true
    }
    
    private func setupConfiguration() {
        var configuration = UIButton.Configuration.plain()
        
        configuration.imagePlacement = .top
        configuration.imagePadding = Matric.imageNamePadding
        configuration.background.backgroundColor = .component(.buttonPurple)
        
        self.configurationUpdateHandler = { button in
            if button.isSelected {
                self.layer.borderColor = UIColor.component(.lightGray).cgColor
            } else {
                self.layer.borderColor = UIColor.component(.fogGray).cgColor
            }
        }
        
        self.configuration = configuration
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.equalTo(Matric.buttonWidth)
            make.height.equalTo(Matric.buttonHeight)
        }
    }
}

private extension CharacterButton {
    func updateConfiguration(title: String) {
        var title = AttributedString(title)
        title.font = .무궁화.title
        title.foregroundColor = .text(.highlight)
        self.configuration?.attributedTitle = title
    }
    
    func updateConfiguration(imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        let resizedImage = image.resized(width: Matric.imageSize, height: Matric.imageSize)
        self.configuration?.image = resizedImage
    }
}

extension CharacterButton {
    func getCharacterFrame() -> CGRect? {
        self.imageView?.frame
    }
}
