//
//  CounselRepositoryProtocol.swift
//  GloomyDiary
//
//  Created by 디해 on 10/14/24.
//

import Foundation

protocol CounselRepositoryProtocol {
    func counsel(to character: CharacterDTO, with userInput: String) async throws -> String
}
