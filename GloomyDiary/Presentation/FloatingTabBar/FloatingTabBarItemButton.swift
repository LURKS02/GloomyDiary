//
//  FloatingTabBarItemButton.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import UIKit

final class FloatingTabBarItemButton: UIButton {
    private var normalImage: UIImage
    private var selectedImage: UIImage
    private let radius: CGFloat
    
    var isSwitched: Bool = false {
        didSet {
            if isSwitched {
                setImage(selectedImage, for: .normal)
            } else {
                setImage(normalImage, for: .normal)
            }
        }
    }
    
    init(item: FloatingTabBarItem, radius: CGFloat) {
        self.normalImage = item.normalImage
        self.selectedImage = item.selectedImage
        self.radius = radius
        
        super.init(frame: .zero)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setImage(normalImage, for: .normal)
        setImage(selectedImage, for: .highlighted)
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(radius)
            make.width.equalTo(radius)
        }
    }
    
    func setButtonImage(isHighlighted: Bool) {
        isSwitched = isHighlighted
    }
    
    func changeThemeIfNeeded() {
        self.selectedImage = selectedImage.withTintColor(AppColor.Component.tabBarItem(true).color)
        self.normalImage = normalImage.withTintColor(AppColor.Component.tabBarItem(false).color)
        
        setup()
        
        if isSwitched {
            setImage(selectedImage, for: .normal)
        }
    }
}
