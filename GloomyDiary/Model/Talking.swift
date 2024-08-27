//
//  Talking.swift
//  GloomyDiary
//
//  Created by 디해 on 8/14/24.
//

import Foundation

enum Talking: CaseIterable {
    case hello
    case cloud
    case walking
    
    var description: String {
        switch self {
        case .hello:
            "안녕!\n오늘은 어떤 고민이 있니?"
        case .cloud:
            "하늘에 있는 구름은\n가끔 보면\n몽실몽실한 소금빵 같아!"
        case .walking:
            "가끔은 마음 편히\n산책이라도 갈까?"
        }
    }
}

extension Talking {
    static func getRandomElement(with previous: Talking) -> Talking {
        Talking.allCases.filter { $0 != previous }.randomElement()!
    }
}
