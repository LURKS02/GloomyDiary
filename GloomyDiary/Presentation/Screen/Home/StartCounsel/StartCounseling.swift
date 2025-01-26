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
        var warning: String = ""
        
        init() {
            @Dependency(\.userSetting) var userSetting
            isFirstProcess = userSetting.get(keyPath: \.isFirstProcess)
        }
    }
    
    enum Action {
        case input(title: String)
        case changeButtonState(Bool)
        case setWarningMessage(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .input(let title):
                return .run { send in
                    if title.count == 0 {
                        await send(.changeButtonState(false))
                        await send(.setWarningMessage(""))
                    }
                    
                    else if !title.isValidContent {
                        await send(.changeButtonState(false))
                        await send(.setWarningMessage("올바르지 않은 형식이에요."))
                    }
                    
                    else {
                        if title.count > 15 {
                            await send(.changeButtonState(false))
                            await send(.setWarningMessage("15자 이하로 작성해주세요."))
                        }
                        
                        else {
                            await send(.changeButtonState(true))
                            await send(.setWarningMessage(""))
                        }
                    }
                }
                
            case .changeButtonState(let possibility):
                state.isSendable = possibility
                return .none
                
            case .setWarningMessage(let message):
                state.warning = message
                return .none
            }
        }
    }
}
