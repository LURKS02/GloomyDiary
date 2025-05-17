//
//  StarlightView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import UIKit

final class StarlightView: UIImageView {
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                image = AppImage.Component.starlight(true).image
            } else {
                image = AppImage.Component.starlight(false).image
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        image = AppImage.Component.starlight(false).image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeThemeIfNeeded() {
        image = AppImage.Component.starlight(isSelected).image
    }
}
