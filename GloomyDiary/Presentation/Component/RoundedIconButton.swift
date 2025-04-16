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
    private let iconSize: CGFloat
    
    init(size: CGFloat, iconName: String, iconSize: CGFloat = 16) {
        self.size = size
        self.iconName = iconName
        self.iconSize = iconSize
        
        super.init(frame: .zero)
        
        setup()
        setupConstraints()
        setupConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCircularShape()
    }
    
    func setup() {
        
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.equalTo(size)
            make.height.equalTo(size)
        }
    }
    
    private func setupConfiguration() {
        var configuration = UIButton.Configuration.plain()
        configuration.background.backgroundColor = AppColor.Component.blackPurple.color
        configuration.baseForegroundColor = .white
        configuration.image = UIImage(systemName: iconName)?.resized(width: iconSize, height: iconSize).withRenderingMode(.alwaysTemplate)
        
        self.configuration = configuration
    }
}
