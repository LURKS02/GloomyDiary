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
        var character: Character
        var counselState: CounselState = .notStarted
    }
    
    enum Action {
        case initialize(Character)
        case startCounseling
        case completeCounseling
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize(let character):
                state.character = character
                
            case .startCounseling:
                guard state.counselState == .notStarted else { return .none }
                state.counselState = .inProgress
                
            case .completeCounseling:
                guard state.counselState == .inProgress else { return .none }
                state.counselState = .completed
            }
            
            return .none
        }
    }
}

enum CounselState {
    case notStarted
    case inProgress
    case completed
}
