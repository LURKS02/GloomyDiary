//
//  AppearanceMode.swift
//  GloomyDiary
//
//  Created by 디해 on 4/21/25.
//

import UIKit

enum AppearanceMode: Codable, CaseIterable {
    case `default`
    case light
    case dark
    
    var name: String {
        switch self {
        case .default:
            "시스템"
        case .light:
            "낮"
        case .dark:
            "밤"
        }
    }
    
    var image: UIImage {
        switch self {
        case .default:
            UIImage(named: "default_preview")!
        case .light:
            UIImage(named: "light_preview")!
        case .dark:
            UIImage(named: "dark_preview")!
        }
    }
    
    var description: String {
        switch self {
        case .default:
            """
            낮에는 해가 뜨고,
            밤에는 달이 뜰거야!
            """
            
        case .dark:
            """
            별빛이 반짝이는
            고요한 밤을 상상해봐.
            """
            
        case .light:
            """
            따스한 햇살이 비치는
            행복한 날이야.
            """
        }
    }
}
