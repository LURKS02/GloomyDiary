//
//  UserDefaultsUserSettingRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 11/19/24.
//

import Foundation

final class UserDefaultsUserSettingRepository: UserSettingRepository {
    static let shared = UserDefaultsUserSettingRepository()
    
    private let userDefaults = UserDefaults.standard
    
    private var userSetting: UserSetting
    private let userSettingKey = "UserSetting"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        let savedData = userDefaults.data(forKey: userSettingKey)
        if let savedData,
           let savedSetting = try? decoder.decode(UserSetting.self, from: savedData) {
            self.userSetting = savedSetting
        } else {
            let initialSetting = UserSetting(isFirstProcess: true)
            guard let encodedData = try? encoder.encode(initialSetting) else { fatalError("can not encode initial setting.") }
            self.userSetting = initialSetting
            userDefaults.set(encodedData, forKey: userSettingKey)
        }
    }
    
    func get<Value>(keyPath: KeyPath<UserSetting, Value>) -> Value {
        return userSetting[keyPath: keyPath]
    }
    
    func update<Value>(keyPath: WritableKeyPath<UserSetting, Value>, value: Value) {
        userSetting[keyPath: keyPath] = value
        save()
    }
}

private extension UserDefaultsUserSettingRepository {
    func save() {
        if let encodedData = try? encoder.encode(userSetting) {
            userDefaults.set(encodedData, forKey: userSettingKey)
        }
    }
}
