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
    @Dependency(\.aiServicable) var aiService
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
        Logger.send(type: .api, "AI 서비스 요청")
        let response = try await aiService.generateResponse(for: userInput, setting: character.systemSetting)
        let session = Session(id: uuid(),
                              counselor: character,
                              title: title,
                              query: userInput,
                              response: response,
                              createdAt: now,
                              weather: weather,
                              emoji: emoji,
                              urls: urls)
        try await counselingSessionRepository.create(session)
        Logger.send(type: .api, "AI 서비스 응답 수신")
        return response
    }
}
