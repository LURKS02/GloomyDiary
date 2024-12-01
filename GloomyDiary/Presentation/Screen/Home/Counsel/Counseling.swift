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
        let title: String
        let weatherIdentifier: String
        let emojiIdentifier: String
        let character: CharacterDTO
    }
    
    enum Action {
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
