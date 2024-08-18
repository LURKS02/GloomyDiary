//
//  Home.swift
//  GloomyDiary
//
//  Created by 디해 on 8/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Home {
    @ObservableState
    struct State: Equatable {
        var talkingType: Talking = .hello
    }
    
    enum Action {
        case ghostTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .ghostTapped:
                state.talkingType = Talking.getRandomElement(with: state.talkingType)
                return .none
            }
        }
    }
}
