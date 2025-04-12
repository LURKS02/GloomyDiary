//
//  CounselRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 10/13/24.
//

import Foundation
import Dependencies

final class CounselRepository: CounselRepositoryProtocol {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    @Dependency(\.aiService) var aiService
    @Dependency(\.logger) var logger
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid
    
    func counsel(with query: Query) async throws -> Session {
        logger.send(.api, "AI 서비스 요청", nil)
        let response = try await aiService.generate(query.body, query.counselor.systemSetting)
        let session = Session(
            id: uuid(),
            counselor: query.counselor,
            title: query.title,
            query: query.body,
            response: response,
            createdAt: now,
            weather: query.weather,
            emoji: query.emoji,
            imageIDs: query.imageIDs
        )
        
        try await counselingSessionRepository.create(session)
        logger.send(.api, "AI 서비스 응답 수신", nil)
        return session
    }
}
