//
//  ChoosingEmoji.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChoosingEmoji {
    @ObservableState
    struct State: Equatable {
        let title: String
        let weatherIdenfitier: String
        var emojiIdentifier: String?
        var isSendable: Bool = false
    }
    
    enum Action {
        case emojiTapped(identifier: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .emojiTapped(let identifier):
                state.emojiIdentifier = identifier
                state.isSendable = true
                return .none
            }
        }
    }
}
