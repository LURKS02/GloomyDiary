//
//  CounselSessionDTO.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation

struct CounselingSessionDTO: Identifiable {
    let id: UUID
    let counselor: CharacterDTO
    let title: String
    let query: String
    let response: String
    let createdAt: Date
    let weather: WeatherDTO
    let emoji: EmojiDTO
    let urls: [URL]
    
    init(id: UUID, counselor: CharacterDTO, title: String, query: String, response: String, createdAt: Date, weather: WeatherDTO, emoji: EmojiDTO, urls: [URL]) {
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

extension CounselingSessionDTO: Equatable {
    static func == (lhs: CounselingSessionDTO, rhs: CounselingSessionDTO) -> Bool {
        return lhs.id == rhs.id &&
        lhs.counselor == rhs.counselor &&
        lhs.title == rhs.title &&
        lhs.query == rhs.query &&
        lhs.response == rhs.response &&
        lhs.createdAt == rhs.createdAt &&
        lhs.weather == rhs.weather &&
        lhs.emoji == rhs.emoji &&
        lhs.urls == rhs.urls
    }
}

extension CounselingSessionDTO: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
