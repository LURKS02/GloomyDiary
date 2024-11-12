//
//  CounselSession.swift
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
    
    init(id: UUID, counselorIdentifier: String, title: String, query: String, response: String, createdAt: Date, weatherIdentifier: String, emojiIdentifier: String) {
        self.id = id
        self.counselorIdentifier = counselorIdentifier
        self.title = title
        self.query = query
        self.response = response
        self.createdAt = createdAt
        self.weatherIdentifier = weatherIdentifier
        self.emojiIdentifier = emojiIdentifier
    }
}
