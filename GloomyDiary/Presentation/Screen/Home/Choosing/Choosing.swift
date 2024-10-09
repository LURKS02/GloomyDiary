//
//  Choosing.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Choosing {
    @ObservableState
    struct State: Equatable {
        let isFirstProcess: Bool = false
        var chosenCharacter: Character? = nil
    }
    
    enum Action {
        case characterTapped(identifier: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .characterTapped(let identifier):
                guard let character = Character(identifier: identifier) else { return .none }
                state.chosenCharacter = character
                return .none
            }
        }
    }
}
