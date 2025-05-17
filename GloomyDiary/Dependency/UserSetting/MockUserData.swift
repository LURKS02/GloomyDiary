//
//  MockUserData.swift
//  GloomyDiary
//
//  Created by 디해 on 1/18/25.
//

import Foundation

final class MockUserData: UserDatabase {
    var data: [PartialKeyPath<UserSetting>: Any?] = [
        \UserSetting.isFirstProcess: true,
        \UserSetting.hasReviewed: false,
        \UserSetting.lastReviewDeclinedDate: nil,
        \UserSetting.hasSuggestedNotification: true,
        \UserSetting.appearanceMode: AppearanceMode.default,
        \UserSetting.isLocked: false,
        \UserSetting.lockHint: ""
    ]

    func get<Value>(keyPath: KeyPath<UserSetting, Value>) -> Value {
        guard let value = data[keyPath] as? Value else {
            fatalError("No mock value for keyPath")
        }
        return value
    }

    func update<Value>(keyPath: WritableKeyPath<UserSetting, Value>, value: Value) throws {
        data[keyPath] = value
    }
}
