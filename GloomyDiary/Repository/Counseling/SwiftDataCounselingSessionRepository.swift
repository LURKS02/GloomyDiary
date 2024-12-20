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
        let sessionDTOs: [CounselingSessionDTO] = sessions.compactMap { $0.toDTO() }
        
        Logger.send(type: .data, "상담 내역 불러오기")
        return sessionDTOs
    }
    
    func create(_ sessionDTO: CounselingSessionDTO) async throws {
        let session = CounselingSession(dto: sessionDTO)
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
        guard let session = try? modelContext.fetch(descriptor).first else { return nil }
        
        Logger.send(type: .data, "상담 내역 조회")
        return session.toDTO()
    }
}
