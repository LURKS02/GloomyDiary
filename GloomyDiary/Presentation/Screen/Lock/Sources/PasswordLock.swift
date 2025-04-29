//
//  PasswordLock.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct PasswordLock {
    enum PasswordState {
        case comfirming
        case mismatch
    }
    
    @ObservableState
    struct State: Equatable {
        let totalPins: Int = 4
        
        var password: String = ""
        var checkFlag: PasswordState = .comfirming
        var prepareForDismiss: Bool = false
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didEnterPassword(String)
    }
    
    enum InnerAction: Equatable {
        case prepareForDismiss
        case changeState(PasswordState)
    }
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {}
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didEnterPassword(let password):
                    state.password = password
                    guard password.count == state.totalPins else { return .none }
                        
                    if password == "1234" {
                        return .run { send in
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            await send(.inner(.prepareForDismiss))
                        }
                    } else {
                        return .run { send in
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            await send(.inner(.changeState(.mismatch)))
                            await send(.inner(.changeState(.comfirming)))
                        }
                    }
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .prepareForDismiss:
                    state.prepareForDismiss = true
                    return .none
                    
                case .changeState(let passwordState):
                    state.password = ""
                    state.checkFlag = passwordState
                    return .none
                }
            }
        }
    }
}
