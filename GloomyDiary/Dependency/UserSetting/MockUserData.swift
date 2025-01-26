//
//  MockUserData.swift
//  GloomyDiary
//
//  Created by 디해 on 1/18/25.
//

import Foundation

final class MockUserData: UserDatabase {
    static let shared = MockUserData()

    private var mockData: [PartialKeyPath<UserSetting>: Any?] = [
        \UserSetting.isFirstProcess: true,
        \UserSetting.hasReviewed: false,
        \UserSetting.lastReviewDeclinedDate: nil,
        \UserSetting.hasSuggestedNotification: true
    ]

    private init() { }

    func get<Value>(keyPath: KeyPath<UserSetting, Value>) -> Value {
        guard let value = mockData[keyPath] as? Value else {
            fatalError("No mock value for keyPath")
        }
        return value
    }

    func update<Value>(keyPath: WritableKeyPath<UserSetting, Value>, value: Value) throws {
        mockData[keyPath] = value
    }
}
