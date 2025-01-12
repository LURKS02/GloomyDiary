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
    let urls: [URL]
    
    init(
        id: UUID,
        counselor: CounselingCharacter,
        title: String,
        query: String,
        response: String,
        createdAt: Date,
        weather: Weather,
        emoji: Emoji,
        urls: [URL]
    ) {
        self.id = id
        self.counselor = counselor
        self.title = title
        self.query = query
        self.response = response
        self.createdAt = createdAt
        self.weather = weather
        self.emoji = emoji
        self.urls = urls
    }
}

extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
    }
}
