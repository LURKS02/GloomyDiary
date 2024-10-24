//
//  CounselSessionDTO.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation

final class CounselingSessionDTO: Sendable, Identifiable {
    let id: UUID
    let counselor: CharacterDTO
    let query: String
    let response: String
    let createdAt: Date
    
    init(id: UUID, counselor: CharacterDTO, query: String, response: String, createdAt: Date) {
        self.id = id
        self.counselor = counselor
        self.query = query
        self.response = response
        self.createdAt = createdAt
    }
}

extension CounselingSessionDTO: Equatable {
    static func == (lhs: CounselingSessionDTO, rhs: CounselingSessionDTO) -> Bool {
        return lhs.id == rhs.id &&
        lhs.counselor == rhs.counselor &&
        lhs.query == rhs.query &&
        lhs.response == rhs.response &&
        lhs.createdAt == rhs.createdAt
    }
}
