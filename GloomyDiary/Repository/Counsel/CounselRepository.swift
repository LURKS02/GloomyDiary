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
    
    func counsel(to character: CharacterDTO, with userInput: String) async throws -> String {
        let response = try await aiService.generateResponse(for: userInput, setting: character.systemSetting)
        let sessionDTO = CounselingSessionDTO(id: UUID(),
                                              counselor: character,
                                              query: userInput,
                                              response: response,
                                              createdAt: .now)
        try await counselingSessionRepository.create(sessionDTO)
        return response
    }
}
