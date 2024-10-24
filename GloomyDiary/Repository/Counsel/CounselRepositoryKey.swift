//
//  CounselRepositoryKey.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation
import Dependencies

private enum CounselRepositoryKey: DependencyKey {
    static var liveValue: CounselRepositoryProtocol = CounselRepository()
}

extension DependencyValues {
    var counselRepository: CounselRepositoryProtocol {
        get { self[CounselRepositoryKey.self] }
        set { self[CounselRepositoryKey.self] = newValue }
    }
}
