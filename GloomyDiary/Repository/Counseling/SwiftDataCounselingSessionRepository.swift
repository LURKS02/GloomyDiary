//
//  SwiftDataCounselingSessionRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 10/21/24.
//

import Foundation
import SwiftData

final class SwiftDataCounselingSessionRepository: CounselingSessionRepository {
    private let swiftDataService = SwiftDataService<CounselingSession>(modelContainer: AppEnvironment.shared.modelContainer)
    
    func fetch() async throws -> [CounselingSessionDTO] {
        let descriptor = FetchDescriptor<CounselingSession>(predicate: nil,
                                                            sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let sessions: [CounselingSession] = try await swiftDataService.fetch(descriptor: descriptor)
        let sessionDTOs: [CounselingSessionDTO] = sessions.compactMap { $0.toDTO() }
        
        Logger.send(type: .data, "상담 내역 불러오기")
        return sessionDTOs
    }
    
    func fetch(pageNumber: Int, pageSize: Int) async throws -> [CounselingSessionDTO] {
        var descriptor = FetchDescriptor<CounselingSession>(predicate: nil,
                                                            sortBy: [
                                                                SortDescriptor(\CounselingSession.createdAt, order: .reverse)])
        descriptor.fetchOffset = pageNumber * pageSize
        descriptor.fetchLimit = pageSize
        descriptor.includePendingChanges = false
        
        let sessions: [CounselingSession] = try await swiftDataService.fetch(descriptor: descriptor)
        let sessionDTOs: [CounselingSessionDTO] = sessions.enumerated().compactMap { $1.toDTO(index: $0) }
        
        Logger.send(type: .data, "상담 내역 불러오기, 페이지: \(pageNumber)")
        return sessionDTOs
    }
    
    func create(_ sessionDTO: CounselingSessionDTO) async throws {
        let session = CounselingSession(dto: sessionDTO)
        await swiftDataService.create(session)
        try await swiftDataService.save()
        Logger.send(type: .data, "상담 내역 저장")
    }
    
    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<CounselingSession>(predicate: #Predicate { $0.id == id })
        guard let session = try? await swiftDataService.fetch(descriptor: descriptor).first else { return }
        await swiftDataService.delete(session)
        try await swiftDataService.save()
        Logger.send(type : .data, "상담 내역 삭제")
    }
    
    func find(id: UUID) async throws -> CounselingSessionDTO? {
        let descriptor = FetchDescriptor<CounselingSession>(predicate: #Predicate { $0.id == id })
        guard let session = try? await swiftDataService.fetch(descriptor: descriptor).first else { return nil }
        Logger.send(type: .data, "상담 내역 조회")
        return session.toDTO()
    }
    
    func initialize() async throws {
        let descriptor = FetchDescriptor<CounselingSession>()
        guard let sessions = try? await swiftDataService.fetch(descriptor: descriptor) else { return }
        
        for session in sessions {
            await swiftDataService.delete(session)
        }
        
        try await swiftDataService.save()
    }
    
    func save() async throws {
        try await swiftDataService.save()
    }
}
