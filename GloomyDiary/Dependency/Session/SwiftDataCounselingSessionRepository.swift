//
//  SwiftDataCounselingSessionRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 10/21/24.
//

import Dependencies
import Foundation
import SwiftData

final class SwiftDataCounselingSessionRepository: CounselingSessionRepository {
    @Dependency(\.logger) var logger
    
    private let swiftDataService = SwiftDataService<SessionData>(
        modelContainer: AppEnvironment.modelContainer
    )
    
    func fetch() async throws -> [Session] {
        let descriptor = FetchDescriptor<SessionData>(predicate: nil,
                                                            sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let datas: [SessionData] = try await swiftDataService.fetch(descriptor: descriptor)
        let sessions: [Session] = datas.compactMap { $0.toDomain() }
        
        logger.send(.data, "상담 내역 불러오기", nil)
        return sessions
    }
    
    func fetch(pageNumber: Int, pageSize: Int) async throws -> [Session] {
        var descriptor = FetchDescriptor<SessionData>(predicate: nil,
                                                            sortBy: [
                                                                SortDescriptor(\SessionData.createdAt, order: .reverse)])
        descriptor.fetchOffset = pageNumber * pageSize
        descriptor.fetchLimit = pageSize
        descriptor.includePendingChanges = false
        
        let datas: [SessionData] = try await swiftDataService.fetch(descriptor: descriptor)
        let sessions: [Session] = datas.compactMap { $0.toDomain() }
        
        logger.send(.data, "상담 내역 불러오기, 페이지: \(pageNumber)", nil)
        return sessions
    }
    
    func create(_ session: Session) async throws {
        let data = SessionData(session: session)
        await swiftDataService.create(data)
        try await swiftDataService.save()
        logger.send(.data, "상담 내역 저장", nil)
    }
    
    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<SessionData>(predicate: #Predicate { $0.id == id })
        guard let session = try? await swiftDataService.fetch(descriptor: descriptor).first else { return }
        await swiftDataService.delete(session)
        try await swiftDataService.save()
        logger.send(.data, "상담 내역 삭제", nil)
    }
    
    func find(id: UUID) async throws -> Session? {
        let descriptor = FetchDescriptor<SessionData>(predicate: #Predicate { $0.id == id })
        guard let session = try? await swiftDataService.fetch(descriptor: descriptor).first else { return nil }
        logger.send(.data, "상담 내역 조회", nil)
        return session.toDomain()
    }
    
    func deleteAll() async throws {
        let descriptor = FetchDescriptor<SessionData>()
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
