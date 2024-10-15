//
//  CounselResult.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CounselResult {
    @ObservableState
    struct State: Equatable {
        var character: Character
        var response: String = ""
    }
}
