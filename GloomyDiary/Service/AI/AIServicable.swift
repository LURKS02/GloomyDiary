//
//  AIServicable.swift
//  GloomyDiary
//
//  Created by 디해 on 10/13/24.
//

import Foundation

protocol AIServicable {
    func generateResponse(for input: String, setting: String) async throws -> String
}
