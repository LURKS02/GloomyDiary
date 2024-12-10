//
//  Font.swift
//  GloomyDiary
//
//  Created by 디해 on 8/2/24.
//

import UIKit.UIFont

extension UIFont {
    final class 온글잎_의연체 {
        static private let fontName: String = "OwnglyphEuiyeonChae"
        
        static let heading: UIFont = UIFont(name: fontName, size: 30)!
        static let subHeading: UIFont = UIFont(name: fontName, size: 27)!
        static let title: UIFont = UIFont(name: fontName, size: 25)!
        static let body: UIFont = UIFont(name: fontName, size: 20)!
        static let tabBar: UIFont = UIFont(name: fontName, size: 15)!
    }
}
