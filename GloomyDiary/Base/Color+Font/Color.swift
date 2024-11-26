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
        case warning = "CC4E74"
        case buttonDisabled = "6D6677"
        case buttonSubHighlight = "9C97A3"
        case subHighlight = "C1BFC5"
        case fogHighlight = "91899A"
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
        case white = "FFFFFF"
        case blackPurple = "231D2B"
        case darkPurple = "282236"
        case fogPurple = "392F46"
        case buttonPurple = "322A3D"
        case buttonDisabledPurple = "3A3047"
        case lightGray = "C7B9B9"
        case fogGray = "5F5562"
        case textFieldGray = "584A69"
        case buttonSelectedBlue = "534D71"
    }
    
    static func component(_ component: Component) -> UIColor {
        UIColor(hex: component.rawValue)
    }
}
