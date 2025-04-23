//
//  AppEnvironment.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import ComposableArchitecture
import Foundation
import SwiftData

enum AppEnvironment {
    static var modelContainer: ModelContainer = {
        let schema = Schema([CounselingSession.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        return try! ModelContainer(
            for: schema,
            migrationPlan: SessionMigrationPlan.self,
            configurations: [modelConfiguration]
        )
    }()
    
    static var appearanceMode: AppearanceMode = {
        @Dependency(\.userSetting) var userSetting
        
        return userSetting.get(keyPath: \.appearanceMode)
    }()
    
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음"
}
