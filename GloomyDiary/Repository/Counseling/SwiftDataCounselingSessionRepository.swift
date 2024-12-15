//
//  SwiftDataCounselingSessionRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 10/21/24.
//

import Foundation
import SwiftData

@ModelActor final actor SwiftDataCounselingSessionRepository: CounselingSessionRepository {
    func fetch() async throws -> [CounselingSessionDTO] {
        let descriptor = FetchDescriptor<CounselingSession>(predicate: nil,
                                                            sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let sessions: [CounselingSession] = try modelContext.fetch(descriptor)
        let sessionDTOs: [CounselingSessionDTO] = sessions.compactMap {
            guard let counselor = CharacterDTO(identifier: $0.counselorIdentifier),
                  let weather = WeatherDTO(identifier: $0.weatherIdentifier),
                  let emoji = EmojiDTO(identifier: $0.emojiIdentifier) else { return nil }
            
            return CounselingSessionDTO(id: $0.id,
                                        counselor: counselor,
                                        title: $0.title,
                                        query: $0.query,
                                        response: $0.response,
                                        createdAt: $0.createdAt,
                                        weather: weather,
                                        emoji: emoji)}
        Logger.send(type: .data, "상담 내역 불러오기")
        return sessionDTOs
    }
    
    func create(_ sessionDTO: CounselingSessionDTO) async throws {
        let session = CounselingSession(id: sessionDTO.id,
                                        counselorIdentifier: sessionDTO.counselor.identifier,
                                        title: sessionDTO.title,
                                        query: sessionDTO.query,
                                        response: sessionDTO.response,
                                        createdAt: sessionDTO.createdAt,
                                        weatherIdentifier: sessionDTO.weather.identifier,
                                        emojiIdentifier: sessionDTO.emoji.identifier)
        modelContext.insert(session)
        try modelContext.save()
        Logger.send(type: .data, "상담 내역 저장")
    }
    
    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<CounselingSession>(predicate: #Predicate { $0.id == id })
        guard let session = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(session)
        try modelContext.save()
        Logger.send(type : .data, "상담 내역 삭제")
    }
    
    func find(id: UUID) async throws -> CounselingSessionDTO? {
        let descriptor = FetchDescriptor<CounselingSession>(predicate: #Predicate { $0.id == id })
        guard let session = try? modelContext.fetch(descriptor).first,
              let counselor = CharacterDTO(identifier: session.counselorIdentifier),
              let weather = WeatherDTO(identifier: session.weatherIdentifier),
              let emoji = EmojiDTO(identifier: session.emojiIdentifier) else { return nil }
        
        Logger.send(type: .data, "상담 내역 조회")
        return CounselingSessionDTO(id: session.id,
                                    counselor: counselor,
                                    title: session.title,
                                    query: session.query,
                                    response: session.response,
                                    createdAt: session.createdAt,
                                    weather: weather,
                                    emoji: emoji)
        
    }
}
