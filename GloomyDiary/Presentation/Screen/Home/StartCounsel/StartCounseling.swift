//
//  StartCounseling.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct StartCounseling {
    @ObservableState
    struct State: Equatable {
        var isFirstProcess: Bool
        var isSendable: Bool = false
        
        init() {
            @Dependency(\.userSettingRepository) var userSettingRepository
            isFirstProcess = userSettingRepository.get(keyPath: \.isFirstProcess)
        }
    }
    
    enum Action {
        case input(title: String)
        case changeButtonState(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .input(let title):
                return .run { send in
                    if title.isValidContent {
                        await send(.changeButtonState(true))
                    } else {
                        await send(.changeButtonState(false))
                    }
                }
                
            case .changeButtonState(let possibility):
                state.isSendable = possibility
                return .none
            }
        }
    }
}
