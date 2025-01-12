//
//  CounselRepositoryProtocol.swift
//  GloomyDiary
//
//  Created by 디해 on 10/14/24.
//

import Foundation

protocol CounselRepositoryProtocol {
    func counsel(to character: CounselingCharacter, title: String, userInput: String, weather: Weather, emoji: Emoji, urls: [URL]) async throws -> String
}
