//
//  Extension+CGFloat.swift
//  GloomyDiary
//
//  Created by 디해 on 12/11/24.
//

import UIKit

extension CGFloat {
    /// 디바이스 화면 크기에 따라 수평으로 계산되는 값
    /// - Parameter value: iPhone 16 Pro에서 설정한 너비
    /// - Returns: 해당 디바이스에 맞춰진 너비
    static func deviceAdjustedWidth(_ value: CGFloat) -> CGFloat {
        let baseWidth: CGFloat = 402
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        return value / baseWidth * screenWidth
    }
    
    /// 디바이스 화면 크기에 따라 수직으로 계산되는 값
    /// - Parameter value: iPhone 16 Pro에서 설정한 높이
    /// - Returns: 해당 디바이스에 맞춰진 높이
    static func deviceAdjustedHeight(_ value: CGFloat) -> CGFloat {
        let baseHeight: CGFloat = 874
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        return value / baseHeight * screenHeight
    }
}
