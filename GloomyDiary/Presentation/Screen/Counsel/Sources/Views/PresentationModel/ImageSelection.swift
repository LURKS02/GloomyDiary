//
//  ImageSelection.swift
//  GloomyDiary
//
//  Created by 디해 on 3/27/25.
//

import UIKit

struct ImageSelection: Hashable {
    let uuid: UUID
    let image: UIImage
    let thumbnailImage: UIImage
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uuid == rhs.uuid
    }
}
