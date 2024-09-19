//
//  RoundButton.swift
//  GloomyDiary
//
//  Created by 디해 on 9/6/24.
//

import UIKit

final class RoundedIconButton: UIButton {
    
    private let size: CGFloat
    private let iconName: String
    
    init(size: CGFloat, iconName: String) {
        self.size = size
        self.iconName = iconName
        
        super.init(frame: .zero)
        
        setup()
        setupConstraints()
        applyCircularShape()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let iconImage = UIImage(systemName: iconName)
        setImage(iconImage, for: .normal)
        
        backgroundColor = .component(.blackPurple)
    }
    
    func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.equalTo(size)
            make.height.equalTo(size)
        }
    }
}
