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
        var isFirst: Bool = false
        var chosenCharacter: Character? = nil
    }
    
    enum Action {
        case characterTapped(tag: Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .characterTapped(let tag):
                switch tag {
                case 0:
                    state.chosenCharacter = .chan
                case 1:
                    state.chosenCharacter = .gomi
                case 2:
                    state.chosenCharacter = .beomji
                default:
                    state.chosenCharacter = nil
                }
                return .none
            }
        }
    }
}
