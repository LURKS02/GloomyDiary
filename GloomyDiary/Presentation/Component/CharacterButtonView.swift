//
//  CharacterChooseView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class CharacterButtonView: BaseView {
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
    
    let button: UIButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .top
        configuration.imagePadding = Matric.imageNamePadding
        configuration.background.backgroundColor = .component(.buttonPurple)
        
        $0.configuration = configuration
        $0.layer.borderWidth = Matric.buttonBorderWidth
        
        $0.configurationUpdateHandler = { button in
            switch button.isSelected {
            case true:
                button.layer.borderColor = UIColor.component(.lightGray).cgColor
            case false:
                button.layer.borderColor = UIColor.component(.fogGray).cgColor
            }
        }
    }
    
    init(characterName: String, characterImage: String) {
        super.init(frame: .zero)
        
        let image = UIImage(named: characterImage)
        let size = CGSize(width: Matric.imageSize, height: Matric.imageSize)
        let resizedImage = UIGraphicsImageRenderer(size: size).image { _ in image?.draw(in: CGRect(origin: .zero, size: size))}
        
        var title = AttributedString(characterName)
        title.font = .무궁화.title
        title.foregroundColor = .text(.highlight)
        self.button.configuration?.attributedTitle = title
        self.button.configuration?.image = resizedImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.button.layer.cornerRadius = Matric.cornerRadius
        self.button.layer.masksToBounds = true
    }
    
    override func addSubviews() {
        addSubview(button)
    }
    
    override func setupConstraints() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(Matric.buttonWidth)
            make.height.equalTo(Matric.buttonHeight)
        }
    }
}
