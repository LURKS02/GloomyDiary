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
    var query: String
    var response: String
    var createdAt: Date
    
    init(id: UUID, counselorIdentifier: String, query: String, response: String, createdAt: Date) {
        self.id = id
        self.counselorIdentifier = counselorIdentifier
        self.query = query
        self.response = response
        self.createdAt = createdAt
    }
}
