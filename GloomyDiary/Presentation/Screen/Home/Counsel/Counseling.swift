//
//  Counseling.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Counseling {
    @ObservableState
    struct State: Equatable {
        var character: CharacterDTO
    }
    
    enum Action {
        case initialize(CharacterDTO)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize(let character):
                state.character = character
                return .none
            }
        }
    }
}
