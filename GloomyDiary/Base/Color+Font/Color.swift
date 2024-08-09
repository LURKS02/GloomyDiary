//
//  AppColor.swift
//  GloomyDiary
//
//  Created by 디해 on 8/2/24.
//

import UIKit.UIColor

extension UIColor {
    enum Text: String {
        case highlight = "FFFFFF"
        case dark = "66626B"
    }
    
    static func text(_ text: Text) -> UIColor {
        UIColor(hex: text.rawValue)
    }
}

extension UIColor {
    enum Background: String {
        case mainPurple = "473B57"
        case darkPurple = "241E2C"
    }
    
    static func background(_ background: Background) -> UIColor {
        UIColor(hex: background.rawValue)
    }
}
