//
//  userSettingKey.swift
//  GloomyDiary
//
//  Created by 디해 on 11/19/24.
//

import Foundation
import Dependencies

private enum UserSettingKey: DependencyKey {
    static var liveValue: any UserDatabase = UserDefaultsData()
    static var testValue: any UserDatabase = MockUserData()
}

extension DependencyValues {
    var userSetting: UserDatabase {
        get {
            self[UserSettingKey.self]
        }
        set {
            self[UserSettingKey.self] = newValue
        }
    }
}
