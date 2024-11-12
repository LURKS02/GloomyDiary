//
//  ChoosingCharacter.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChoosingCharacter {
    @ObservableState
    struct State: Equatable {
        let title: String
        let weatherIdentifier: String
        let emojiIdentifier: String
        var character: CharacterDTO = .chan
    }
    
    enum Action {
        case characterSelected(identifier: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .characterSelected(let identifier):
                guard let character = CharacterDTO(identifier: identifier) else { return .none }
                state.character = character
                return .none
            }
        }
    }
}
