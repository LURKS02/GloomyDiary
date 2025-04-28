//
//  MockCounselingSessionRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 4/13/25.
//

import Foundation

final class MockCounselingSessionRepository: CounselingSessionRepository {
    
    var sessions: [Session] = [
        Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: .now,
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
    ]
    
    init() { }
    
    init(sessions: [Session]) {
        self.sessions = sessions
    }
    
    func fetch() async throws -> [Session] {
        return sessions
    }
    
    func fetch(pageNumber: Int, pageSize: Int) async throws -> [Session] {
        return sessions
    }
    
    func create(_ session: Session) async throws {
        sessions.append(session)
    }

    func delete(id: UUID) async throws {
        sessions = sessions.filter { $0.id != id }
    }
    
    func find(id: UUID) async throws -> Session? {
        return sessions.first(where: { $0.id == id })
    }
    
    func deleteAll() async throws {
        sessions = []
    }
    
    func save() async throws {
        return
    }
}
