//
//  Extension+CGFloat.swift
//  GloomyDiary
//
//  Created by 디해 on 12/11/24.
//

import UIKit

extension CGFloat {
    static func horizontalValue(_ value: CGFloat) -> CGFloat {
        let baseWidth: CGFloat = 402
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        return value / baseWidth * screenWidth
    }
    
    static func verticalValue(_ value: CGFloat) -> CGFloat {
        let baseHeight: CGFloat = 874
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        return value / baseHeight * screenHeight
    }
}
