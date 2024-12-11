//
//  Extension+UIView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/6/24.
//

import UIKit

extension UIView {
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    var flattenSubviews: [UIView] {
        [self] + self.subviews.flatMap { $0.flattenSubviews }
    }
    
    func applyCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    func applyCircularShape() {
        let halfWidth = self.bounds.width / 2
        let halfHeight = self.bounds.height / 2
        
        self.layer.cornerRadius = min(halfWidth, halfHeight)
        self.layer.masksToBounds = true
    }
}
