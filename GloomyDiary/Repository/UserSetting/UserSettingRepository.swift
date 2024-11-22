//
//  UserSettingRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 11/19/24.
//

import Foundation

protocol UserSettingRepository {
    func get<Value>(keyPath: KeyPath<UserSetting, Value>) -> Value
    func update<Value>(keyPath: WritableKeyPath<UserSetting, Value>, value: Value)
}
