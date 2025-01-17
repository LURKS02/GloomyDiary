//
//  Session.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation

struct Session: Identifiable, Hashable {
    let id: UUID
    let counselor: CounselingCharacter
    let title: String
    let query: String
    let response: String
    let createdAt: Date
    let weather: Weather
    let emoji: Emoji
    let imageIDs: [UUID]
    
    init(
        id: UUID,
        counselor: CounselingCharacter,
        title: String,
        query: String,
        response: String,
        createdAt: Date,
        weather: Weather,
        emoji: Emoji,
        imageIDs: [UUID]
    ) {
        self.id = id
        self.counselor = counselor
        self.title = title
        self.query = query
        self.response = response
        self.createdAt = createdAt
        self.weather = weather
        self.emoji = emoji
        self.imageIDs = imageIDs
    }
}

extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
    }
}
