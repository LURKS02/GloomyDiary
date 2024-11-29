//
//  LocalNotificationType.swift
//  GloomyDiary
//
//  Created by 디해 on 11/28/24.
//

import Foundation

enum LocalNotificationType: CaseIterable {
    case chan
    case gomi
    case beomji
    
    var title: String {
        switch self {
        case .chan:
            "찬이가 편지를 기다리고 있어요."
        case .gomi:
            "고미가 심심해 보여요."
        case .beomji:
            "범지가 할 말이 있나봐요."
        }
    }
    
    var body: String {
        switch self {
        case .chan:
            "아직 편지가 오지 않았네. 오늘은 어떤 이야기를 해줄지 너무 기대돼!"
        case .gomi:
            "오늘 하루는 잘 보냈어? 딱히 편지를 기다리는 건 아니야... 그래도 얼른 네 이야기가 듣고 싶어."
        case .beomji:
            "안녕~ 오늘 많이 바빴지? 그래도 괜찮다면 들러서 이야기 나눠줘~ 네 하루가 궁금해~"
        }
    }
}

extension LocalNotificationType {
    static func randomElement() -> LocalNotificationType {
        LocalNotificationType.allCases.randomElement()!
    }
}
