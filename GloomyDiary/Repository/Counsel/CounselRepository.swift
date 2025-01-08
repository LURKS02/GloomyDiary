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
    
    func counsel(to character: CharacterDTO, title: String, userInput: String, weather: WeatherDTO, emoji: EmojiDTO, urls: [URL]) async throws -> String {
        Logger.send(type: .api, "AI 서비스 요청")
        let response = try await aiService.generateResponse(for: userInput, setting: character.systemSetting)
        let sessionDTO = CounselingSessionDTO(id: uuid(),
                                              counselor: character,
                                              title: title,
                                              query: userInput,
                                              response: response,
                                              createdAt: now,
                                              weather: weather,
                                              emoji: emoji,
                                              urls: urls)
        try await counselingSessionRepository.create(sessionDTO)
        Logger.send(type: .api, "AI 서비스 응답 수신")
        return response
    }
}
