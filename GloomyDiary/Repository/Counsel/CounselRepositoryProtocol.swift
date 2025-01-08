//
//  CounselRepositoryProtocol.swift
//  GloomyDiary
//
//  Created by 디해 on 10/14/24.
//

import Foundation

protocol CounselRepositoryProtocol {
    func counsel(to character: CharacterDTO, title: String, userInput: String, weather: WeatherDTO, emoji: EmojiDTO, urls: [URL]) async throws -> String
}
