//
//  CounselingSessionRepositoryKey.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation
import Dependencies

private enum CounselingSessionRepositoryKey: DependencyKey {
    static var liveValue: any CounselingSessionRepository = SwiftDataCounselingSessionRepository()
    static var testValue: any CounselingSessionRepository = MockCounselingSessionRepository()
}

extension DependencyValues {
    var counselingSessionRepository: CounselingSessionRepository {
        get { self[CounselingSessionRepositoryKey.self] }
        set { self[CounselingSessionRepositoryKey.self] = newValue }
    }
}
