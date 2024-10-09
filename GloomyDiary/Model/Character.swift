//
//  Character.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import Foundation

enum Character: String, CaseIterable {
    case chan = "chan"
    case gomi = "gomi"
    case beomji = "beomji"
    
    init?(identifier: String) {
        self.init(rawValue: identifier)
    }
    
    var identifier: String {
        self.rawValue
    }
    
    var name: String {
        switch self {
        case .chan:
            "찬이"
        case .gomi:
            "고미"
        case .beomji:
            "범지"
        }
    }
    
    var imageName: String {
        switch self {
        case .chan:
            "chan"
        case .gomi:
            "gomi"
        case .beomji:
            "beomji"
        }
    }
    
    var introduceMessage: String {
        switch self {
        case .chan:
            "나는 찬이야!\n" +
            "\n" +
            "나는 언제나 너의 편이 되어주는\n" +
            "든든한 친구야.\n" +
            "\n" +
            "나에게 상담한다면\n" +
            "네 마음을 잘 알아줄거야."
            
        case .gomi:
            "나는 고미야.\n" +
            "\n" +
            "나는 조금은 까칠하지만\n" +
            "너에게 현명한 조언을 해줄 수 있어.\n" +
            "\n" +
            "나에게 상담한다면\n" +
            "좋은 해결책을 찾을지도 몰라."
            
        case .beomji:
            "나는 범지야~\n" +
            "\n" +
            "나는 느긋하고\n" +
            "차분한 성격을 가지고 있어.\n" +
            "\n" +
            "마음이 급하거나 불안할 때는\n" +
            "나에게 상담해봐~"
        }
    }
    
    var greetingMessage: String {
        switch self {
        case .chan:
            "안녕! 나는 찬이야.\n" +
            "오늘은 어떤 고민이 있어서 찾아온거니?\n" +
            "\n" +
            "고민, 걱정, 생각 등\n" +
            "나에게 하고 싶은 말을 편지로 보내줘!"
            
        case .gomi:
            "안녕? 난 고미야.\n" +
            "오늘은 어떤 일로 찾아온거야?\n" +
            "\n" +
            "무슨 일이 있었는지\n" +
            "나에게 편지를 보내줘."
            
        case .beomji:
            "안녕~ 나는 범지야.\n" +
            "불안하거나 초조한 일이 있었니?\n" +
            "\n" +
            "걱정 말고 편한 마음으로\n" +
            "편지를 보내주라~"
        }
    }
    
    var counselReadyMessage: String {
        switch self {
        case .chan:
            "보물 창고를 뒤적이는 중 ..."
        case .gomi:
            "꽁꽁 얽힌 실타래를 푸는 중 ..."
        case .beomji:
            "읽던 책을 정리하는 중 ..."
        }
    }
}
