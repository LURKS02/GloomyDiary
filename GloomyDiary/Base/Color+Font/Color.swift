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
        case darkPurple = "1B1938"
    }
    
    static func background(_ background: Background) -> UIColor {
        UIColor(hex: background.rawValue)
    }
}

extension UIColor {
    enum Component: String {
        case darkPurple = "282236"
        case buttonPurple = "322A3D"
        case lightGray = "C7B9B9"
        case fogGray = "5F5562"
    }
    
    static func component(_ component: Component) -> UIColor {
        UIColor(hex: component.rawValue)
    }
}
