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
    
    func counsel(
        to character: CounselingCharacter,
        title: String,
        userInput: String,
        weather: Weather,
        emoji: Emoji,
        imageIDs: [UUID]
    ) async throws -> String {
        logger.send(.api, "AI 서비스 요청", nil)
        let response = try await aiService.generate(userInput, character.systemSetting)
        let session = Session(id: uuid(),
                              counselor: character,
                              title: title,
                              query: userInput,
                              response: response,
                              createdAt: now,
                              weather: weather,
                              emoji: emoji,
                              imageIDs: imageIDs)
        try await counselingSessionRepository.create(session)
        logger.send(.api, "AI 서비스 응답 수신", nil)
        return response
    }
}
