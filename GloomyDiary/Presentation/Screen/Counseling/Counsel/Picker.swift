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
        var selectedIDs: [UUID]
    }
    
    enum Action: Equatable {
        case addImages([UUID])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addImages(let ids):
                state.selectedIDs += ids
                
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
