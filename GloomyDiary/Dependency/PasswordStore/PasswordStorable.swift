//
//  PasswordStorable.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import Foundation

protocol PasswordStorable {
    func save(password: String)
    func load() async throws -> String
}
