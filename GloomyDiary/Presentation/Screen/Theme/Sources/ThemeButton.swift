//
//  ThemeButton.swift
//  GloomyDiary
//
//  Created by 디해 on 4/21/25.
//

import UIKit

final class ThemeButton: UIButton {
    
    let identifier: Int
    
    init(theme: AppearanceMode, identifier: Int) {
        self.identifier = identifier
        super.init(frame: .zero)
        
        setupConfiguration(with: theme)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyCornerRadius(20)
    }
    
    private func setupConfiguration(with theme: AppearanceMode) {
        self.setImage(theme.image, for: .normal)
        self.contentHorizontalAlignment = .fill
        self.contentVerticalAlignment = .fill
    }
}

