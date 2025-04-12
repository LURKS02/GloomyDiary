//
//  Query.swift
//  GloomyDiary
//
//  Created by 디해 on 4/2/25.
//

import UIKit

struct Query: Equatable {
    let counselor: CounselingCharacter
    let title: String
    let body: String
    let weather: Weather
    let emoji: Emoji
    let images: [UIImage]
    let imageIDs: [UUID]
}
