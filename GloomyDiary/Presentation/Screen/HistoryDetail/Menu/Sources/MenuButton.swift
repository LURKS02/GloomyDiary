//
//  MenuButton.swift
//  GloomyDiary
//
//  Created by 디해 on 12/13/24.
//

import UIKit

final class MenuButton: UIButton {
    
    let item: MenuItem
    
    init(item: MenuItem) {
        self.item = item
        super.init(frame: .zero)
        
        configure(with: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: MenuItem) {
        var configuration = Configuration.plain()
        var title = AttributedString(item.name)
        let type = item.type
        let fontColor: UIColor = (type == .warning) ? AppColor.Text.warning.color : AppColor.Text.subHighlight.color
        title.font = .온글잎_의연체.title
        configuration.attributedTitle = title
        self.configuration = configuration
        
        configurationUpdateHandler = { button in
            guard var updatedConfiguration = button.configuration,
                  let currentAttributedTitle = updatedConfiguration.attributedTitle else { return }
            let title = String(currentAttributedTitle.characters)
            var attributedTitle = AttributedString(title)
            
            if button.isHighlighted {
                attributedTitle.foregroundColor = AppColor.Text.highlight.color
            } else {
                attributedTitle.foregroundColor = fontColor
            }
            attributedTitle.font = .온글잎_의연체.title
            updatedConfiguration.attributedTitle = attributedTitle
            button.configuration = updatedConfiguration
        }
    }
}
