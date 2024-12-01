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
        var character: CharacterDTO
        var request: String
        var response: String = ""
    }
    
    enum Action {
        case updateResponse(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateResponse(let response):
                state.response = response
                return .none
            }
        }
    }
}
