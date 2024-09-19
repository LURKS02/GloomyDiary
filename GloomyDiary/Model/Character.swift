//
//  Character.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import Foundation

enum Character: CaseIterable {
    case chan
    case gomi
    case beomji
    
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
        }
    }
}
