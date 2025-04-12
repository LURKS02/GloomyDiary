//
//  MenuItem.swift
//  GloomyDiary
//
//  Created by 디해 on 12/13/24.
//

import Foundation

enum MenuItem: String {
    case delete
    case share
    
    init?(identifier: String) {
        self.init(rawValue: identifier)
    }
    
    var identifier: String {
        self.rawValue
    }
    
    var name: String {
        switch self {
        case .delete:
            "삭제하기"
        case .share:
            "공유하기"
        }
    }
    
    var type: MenuType {
        switch self {
        case .delete:
            .warning
        case .share:
            .normal
        }
    }
}

extension MenuItem {
    enum MenuType {
        case normal
        case warning
    }
}
