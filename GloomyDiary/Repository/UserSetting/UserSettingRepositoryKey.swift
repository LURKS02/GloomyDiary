//
//  UserSettingRepositoryKey.swift
//  GloomyDiary
//
//  Created by 디해 on 11/19/24.
//

import Foundation
import Dependencies

private enum UserSettingRepositoryKey: DependencyKey {
    static var liveValue: any UserSettingRepository = UserDefaultsUserSettingRepository.shared
}

extension DependencyValues {
    var userSettingRepository: UserSettingRepository {
        get {
            self[UserSettingRepositoryKey.self]
        }
        set {
            self[UserSettingRepositoryKey.self] = newValue
        }
    }
}
