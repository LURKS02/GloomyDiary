//
//  PasswordStoreKey.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import Dependencies
import Foundation

private enum PasswordStoreKey: DependencyKey {
    static let liveValue: PasswordStorable = BiometricPasswordStore()
}

extension DependencyValues {
    var passwordStore: PasswordStorable {
        get { self[PasswordStoreKey.self] }
        set { self[PasswordStoreKey.self] = newValue }
    }
}
