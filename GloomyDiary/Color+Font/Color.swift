//
//  AppColor.swift
//  GloomyDiary
//
//  Created by 디해 on 8/2/24.
//

import UIKit.UIColor

extension UIColor {
    enum Background: String {
        case mainPurple = "473B57"
    }
    
    static func background(_ background: Background) -> UIColor {
        UIColor(hex: background.rawValue)
    }
}
