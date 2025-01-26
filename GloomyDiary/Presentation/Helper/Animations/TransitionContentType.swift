//
//  TransitionContentType.swift
//  GloomyDiary
//
//  Created by 디해 on 1/24/25.
//

import Foundation

enum TransitionContentType {
    case normalTransition
    case frameTransition
    case switchedHierarchyTransition
    case frameTransitionWithLottie(CounselingCharacter)
    case frameTransitionWithClosure(CounselingCharacter, closure: () async throws -> String)
}
