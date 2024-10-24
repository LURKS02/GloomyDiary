//
//  AIServicableKey.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation
import Dependencies

private enum AIServicableKey: DependencyKey {
    static var liveValue: any AIServicable = ChatGPTService.shared
}

extension DependencyValues {
    var aiServicable: AIServicable {
        get { self[AIServicableKey.self] }
        set { self[AIServicableKey.self] = newValue }
    }
}
