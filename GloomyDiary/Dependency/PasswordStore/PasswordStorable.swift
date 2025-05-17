//
//  PasswordStorable.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import Foundation

protocol PasswordStorable {
    func save(password: String)
    func saveWithBiometrics(password: String)
    
    func load() async -> String?
    func loadWithBiometrics() async -> String?
    
    func delete()
    func deleteBiometrics()
}
