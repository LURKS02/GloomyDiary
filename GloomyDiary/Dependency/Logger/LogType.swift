//
//  LogType.swift
//  GloomyDiary
//
//  Created by 디해 on 1/18/25.
//

import Foundation

extension Logger {
    enum LogType {
        case screen
        case tapped
        case app
        case api
        case data
        case system
        
        var keyword: String {
            switch self {
            case .screen:
                "Screen"
            case .tapped:
                "Tap Event"
            case .app:
                "App"
            case .api:
                "Network"
            case .data:
                "Data"
            case .system:
                "System"
            }
        }
        
        var description: String {
            switch self {
            case .screen:
                "화면 진입"
            case .tapped:
                "을(를) 눌렀습니다."
            case .app:
                ""
            case .api:
                ""
            case .data:
                ""
            case .system:
                ""
            }
        }
    }
}
