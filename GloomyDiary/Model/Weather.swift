//
//  Weather.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation

enum Weather: String, CaseIterable {
    case sunny
    case cloudy
    case thunder
    case rainy
    case snowy
    
    init?(identifier: String) {
        self.init(rawValue: identifier)
    }
    
    var identifier: String {
        self.rawValue
    }
    
    var name: String {
        switch self {
        case .sunny:
            "맑음"
        case .cloudy:
            "흐림"
        case .thunder:
            "번개"
        case .rainy:
            "비"
        case .snowy:
            "눈"
        }
    }
    
    var imageName: String {
        self.rawValue
    }
}

extension Weather {
    static func getRandomElement() -> Weather {
        Weather.allCases.randomElement()!
    }
}
