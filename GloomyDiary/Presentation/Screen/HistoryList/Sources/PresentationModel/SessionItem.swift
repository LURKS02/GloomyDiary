//
//  Sessionitem.swift
//  GloomyDiary
//
//  Created by 디해 on 4/3/25.
//

import Foundation

struct SessionItem: Hashable {
    let uuid: UUID
    let session: Session
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uuid == rhs.uuid
    }
}
