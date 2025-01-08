//
//  AppEnvironment.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation
import SwiftData

final class AppEnvironment {
    static let shared = AppEnvironment()
    
    var modelContainer: ModelContainer
    
    private init() {
        let schema = Schema([CounselingSession.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.modelContainer = try! ModelContainer(
            for: schema,
            migrationPlan: SessionMigrationPlan.self,
            configurations: [modelConfiguration]
        )
    }
}
