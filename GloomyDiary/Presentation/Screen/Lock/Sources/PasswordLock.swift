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
    @Dependency(\.passwordStore) var passwordStore
    @Dependency(\.userSetting) var userSetting
    
    enum PasswordState {
        case comfirming
        case mismatch
    }
    
    @ObservableState
    struct State: Equatable {
        let totalPins: Int = 4
        var keychainPassword: String = ""
        
        var hint: String = ""
        var password: String = ""
        var checkFlag: PasswordState = .comfirming
        var prepareForDismiss: Bool = false
        var didSucceed: Bool = false
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didEnterPassword(String)
        case viewDidLoad
        case viewDidAppear
        case didTapDismissButton
    }
    
    enum InnerAction: Equatable {
        case didLoadPassword(String)
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
                case .viewDidLoad:
                    state.hint = "힌트: " + userSetting.get(keyPath: \.lockHint)
                    
                    return .run { send in
                        let password = await passwordStore.load() ?? ""
                        await send(.inner(.didLoadPassword(password)))
                    }
                    
                case .viewDidAppear:
                    return .run { send in
                        guard let result = await passwordStore.loadWithBiometrics() else { return }
                        
                        await send(.view(.didEnterPassword(result)))
                    }
                    
                case .didEnterPassword(let password):
                    state.password = password
                    guard password.count == state.totalPins else { return .none }
                        
                    if password == state.keychainPassword {
                        state.didSucceed = true
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
                    
                case .didTapDismissButton:
                    return .run { send in
                        await send(.inner(.prepareForDismiss))
                    }
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .didLoadPassword(let password):
                    state.keychainPassword = password
                    return .none
                    
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
