//
//  CounselingSession.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import Foundation
import SwiftData

@Model
final class CounselingSession {
    @Attribute(.unique) var id: UUID
    var counselorIdentifier: String
    var title: String
    var query: String
    var response: String
    var createdAt: Date
    var weatherIdentifier: String
    var emojiIdentifier: String
    @Attribute(.transformable(by: ArrayTransformer.name.rawValue)) var images: [String]

    init(id: UUID, counselorIdentifier: String, title: String, query: String, response: String, createdAt: Date, weatherIdentifier: String, emojiIdentifier: String, images: [String] = []) {
        self.id = id
        self.counselorIdentifier = counselorIdentifier
        self.title = title
        self.query = query
        self.response = response
        self.createdAt = createdAt
        self.weatherIdentifier = weatherIdentifier
        self.emojiIdentifier = emojiIdentifier
        self.images = images
    }
}

extension CounselingSession {
    convenience init(dto: CounselingSessionDTO) {
        self.init(id: dto.id,
                  counselorIdentifier: dto.counselor.identifier,
                  title: dto.title,
                  query: dto.query,
                  response: dto.response,
                  createdAt: dto.createdAt,
                  weatherIdentifier: dto.weather.identifier,
                  emojiIdentifier: dto.emoji.identifier,
                  images: dto.urls.map { $0.lastPathComponent })
    }
    
    func toDTO() -> CounselingSessionDTO? {
        guard let counselor = CharacterDTO(identifier: self.counselorIdentifier),
              let weather = WeatherDTO(identifier: self.weatherIdentifier),
              let emoji = EmojiDTO(identifier: self.emojiIdentifier) else { return nil }
        
        return CounselingSessionDTO(id: self.id,
                                    counselor: counselor,
                                    title: self.title,
                                    query: self.query,
                                    response: self.response,
                                    createdAt: self.createdAt,
                                    weather: weather,
                                    emoji: emoji,
                                    urls: images.map { ImageFileManager.shared.getImageURL(fileName: $0) })
    }
}
