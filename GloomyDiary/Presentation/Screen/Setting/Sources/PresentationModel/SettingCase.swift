//
//  SettingCase.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import Foundation

enum SettingCase {
    case version
    case theme
    
    var title: String {
        switch self {
        case .version:
            "앱 버전"
        case .theme:
            "테마"
        }
    }
}
