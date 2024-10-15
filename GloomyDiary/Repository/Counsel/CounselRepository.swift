//
//  CounselRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 10/13/24.
//

import Foundation

final class CounselRepository: CounselRepositoryProtocol {
    let aiService: AIServicable
    
    init(aiService: AIServicable) {
        self.aiService = aiService
    }
    
    func counsel(to character: Character, with userInput: String) async throws -> String {
        let response = try await aiService.generateResponse(for: userInput, setting: character.systemSetting)
        return response
    }
}
