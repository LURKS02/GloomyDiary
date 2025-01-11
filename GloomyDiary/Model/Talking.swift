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
    case sky
    case pudding
    
    var description: String {
        switch self {
        case .hello:
            """
            안녕!
            오늘은 어떤 일이 있었니?
            """
        case .cloud:
            """
            하늘에 있는 구름은
            가끔 보면
            몽실몽실한 소금빵 같아!
            """
        case .walking:
            """
            가끔은 마음 편히
            산책이라도 갈까?
            """
        case .sky:
            """
            밤하늘에
            반짝이는 별이 가득해!
            """
        case .pudding:
            """
            달콤한 커스터드 푸딩이
            먹고 싶은데...
            """
        }
    }
}

extension Talking {
    static func getRandomElement(with previous: Talking) -> Talking {
        Talking.allCases.filter { $0 != previous }.randomElement()!
    }
}
