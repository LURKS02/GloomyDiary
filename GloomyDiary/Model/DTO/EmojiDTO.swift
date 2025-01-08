//
//  EmojiDTO.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation

enum EmojiDTO: String, CaseIterable {
    case happy
    case sad
    case normal
    case surprised
    case hard
    case excited
    case angry
    case confused
    case embarrassed
    
    init?(identifier: String) {
        self.init(rawValue: identifier)
    }
    
    var identifier: String {
        self.rawValue
    }
    
    var description: String {
        switch self {
        case .happy:
            "행복"
        case .sad:
            "슬픔"
        case .normal:
            "보통"
        case .surprised:
            "놀라움"
        case .hard:
            "피로"
        case .excited:
            "파티"
        case .angry:
            "화남"
        case .confused:
            "멘붕"
        case .embarrassed:
            "부끄러움"
        }
    }
    
    var imageName: String {
        self.rawValue
    }
}

extension EmojiDTO {
    static func getRandomElement() -> EmojiDTO {
        EmojiDTO.allCases.randomElement()!
    }
}
