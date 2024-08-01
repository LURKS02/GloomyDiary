//
//  UIColor+Hex.swift
//  GloomyDiary
//
//  Created by 디해 on 8/2/24.
//

import UIKit.UIColor

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let scanner = Scanner(string: hexSanitized)
        
        if hexSanitized.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000FF) / 255
            
            self.init(red: r, green: g, blue: b, alpha: alpha)
        } else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
        }
    }
}
