//
//  ThemeSchedulerKey.swift
//  GloomyDiary
//
//  Created by 디해 on 4/24/25.
//

import Dependencies
import Foundation

private enum ThemeSchedulerKey: DependencyKey {
    #if DEBUG
    static let liveValue: ThemeScheduling = MockThemeScheduler()
    #else
    static let liveValue: ThemeScheduling = ThemeScheduler()
    #endif
}

extension DependencyValues {
    var themeScheduler: ThemeScheduling {
        get { self[ThemeSchedulerKey.self] }
        set { self[ThemeSchedulerKey.self] = newValue }
    }
}
