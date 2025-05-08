//
//  UserDataImpl.swift
//  GloomyDiary
//
//  Created by 디해 on 11/19/24.
//

import Foundation

final class UserDefaultsData: UserDatabase {
    private let userDefaults = UserDefaults.standard
    private let key = "UserSetting"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var setting: UserSetting
    
    init() {
        let savedData = userDefaults.data(forKey: key)
        if let savedData,
           let savedSetting = try? decoder.decode(UserSetting.self, from: savedData) {
            self.setting = savedSetting
            guard let encodedData = try? encoder.encode(savedSetting) else { fatalError("initial setting encoding error") }
            userDefaults.set(encodedData, forKey: key)
        } else {
            let initialSetting = UserSetting(
                userID: UUID(),
                isFirstProcess: true,
                hasReviewed: false,
                lastReviewDeclinedDate: nil,
                hasSuggestedNotification: false,
                appearanceMode: .default
            )
            guard let encodedData = try? encoder.encode(initialSetting) else { fatalError("initial setting encoding error") }
            self.setting = initialSetting
            userDefaults.set(encodedData, forKey: key)
        }
    }
    
    func get<Value>(keyPath: KeyPath<UserSetting, Value>) -> Value {
        return setting[keyPath: keyPath]
    }
    
    func update<Value>(keyPath: WritableKeyPath<UserSetting, Value>, value: Value) throws {
        setting[keyPath: keyPath] = value
        let encodedData = try encoder.encode(setting)
        userDefaults.set(encodedData, forKey: key)
    }
}
