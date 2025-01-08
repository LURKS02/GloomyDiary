//
//  CounselingViewItem.swift
//  GloomyDiary
//
//  Created by 디해 on 12/19/24.
//

import UIKit

enum CounselingViewItem: Hashable {
    case selectItem(count: Int, maxCount: Int)
    case photoItem(UUID, url: URL)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .selectItem(let count, let maxCount):
            hasher.combine(count)
            hasher.combine(maxCount)
            
        case .photoItem(let id, _):
            hasher.combine(id)
        }
    }
    
    static func == (lhs: CounselingViewItem, rhs: CounselingViewItem) -> Bool {
        switch (lhs, rhs) {
        case let (.selectItem(count1, maxCount1), .selectItem(count2, maxCount2)):
            return count1 == count2 && maxCount1 == maxCount2
            
        case let (.photoItem(id1, _), .photoItem(id2, _)):
            return id1 == id2
            
        default:
            return false
        }
    }
}
