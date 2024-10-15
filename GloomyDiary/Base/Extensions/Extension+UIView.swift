//
//  Extension+UIView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/6/24.
//

import UIKit

extension UIView {
    func applyCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func applyCircularShape() {
        let halfWidth = self.bounds.width / 2
        let halfHeight = self.bounds.height / 2
        
        self.layer.cornerRadius = min(halfWidth, halfHeight)
        self.layer.masksToBounds = true
    }
}
