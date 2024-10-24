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
            guard let counselor = CharacterDTO(rawValue: $0.counselorIdentifier) else { return nil }
            return CounselingSessionDTO(id: $0.id,
                                        counselor: counselor,
                                        query: $0.query,
                                        response: $0.response,
                                        createdAt: $0.createdAt)}
        return sessionDTOs
    }
    
    func create(_ sessionDTO: CounselingSessionDTO) async throws {
        let session = CounselingSession(id: sessionDTO.id,
                                        counselorIdentifier: sessionDTO.counselor.identifier,
                                        query: sessionDTO.query,
                                        response: sessionDTO.response,
                                        createdAt: sessionDTO.createdAt)
        modelContext.insert(session)
        try modelContext.save()
    }
    
    func delete(id: UUID) async throws {
        guard let sessionDTO = try await find(id: id) else { return }
        let session = CounselingSession(id: sessionDTO.id,
                                        counselorIdentifier: sessionDTO.counselor.identifier,
                                        query: sessionDTO.query,
                                        response: sessionDTO.response,
                                        createdAt: sessionDTO.createdAt)
        modelContext.delete(session)
        try modelContext.save()
    }
    
    func find(id: UUID) async throws -> CounselingSessionDTO? {
        let descriptor = FetchDescriptor<CounselingSession>(predicate: #Predicate { $0.id == id })
        guard let session = try? modelContext.fetch(descriptor).first,
              let counselor = CharacterDTO(rawValue: session.counselorIdentifier) else { return nil }
        let sessionDTO = CounselingSessionDTO(id: session.id,
                                              counselor: counselor,
                                              query: session.query,
                                              response: session.response,
                                              createdAt: session.createdAt)
        return sessionDTO
    }
}
