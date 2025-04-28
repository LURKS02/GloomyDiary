//
//  Picker.swift
//  GloomyDiary
//
//  Created by 디해 on 2/17/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Picker {
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable {
        let selectionLimit: Int
    }
    
    enum Action: Equatable {
        case finishSelections
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .finishSelections:
                return .run { _ in
                    await dismiss()
                }
//            case .addSelections(let selections):
//                state.selections += selections
//                
//                return .run { _ in
//                    await dismiss()
//                }
            }
        }
    }
}
