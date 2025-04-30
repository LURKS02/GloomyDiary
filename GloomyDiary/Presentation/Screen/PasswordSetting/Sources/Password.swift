//
//  Password.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Password {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.passwordStore) var passwordStore
    @Dependency(\.userSetting) var userSetting
    
    enum PasswordState {
        case initial
        case resetForConfirmation
        case mismatch
        case confirming
        case confirmed
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var delete: Alert.State?
        
        let totalPins: Int = 4
        
        var initialPassword: String = ""
        var confirmingPassword: String = ""
        var checkFlag: PasswordState = .initial
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapBackButton
        case didEnterPassword(String)
        case didTapDeleteButton
    }
    
    enum InnerAction: Equatable {
        case changeState(PasswordState)
        case didResetForConfirmation
    }
    
    @CasePathable
    enum ScopeAction: Equatable {
        case delete(PresentationAction<Alert.Action>)
    }
    
    enum DelegateAction: Equatable {
        case navigateToRecoveryHint(String)
        case popPassword
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapBackButton:
                    return .run { _ in
                        await dismiss()
                    }
                    
                case .didTapDeleteButton:
                    state.delete = .init()
                    return .none
                    
                case .didEnterPassword(let password):
                    switch state.checkFlag {
                    case .initial:
                        state.initialPassword = password
                        guard password.count == state.totalPins else { return .none }
                        
                        return .run { send in
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            
                            await send(.inner(.changeState(.resetForConfirmation)))
                            await send(.inner(.didResetForConfirmation))
                        }
                        
                    case .confirming:
                        state.confirmingPassword = password
                        
                        guard password.count == state.totalPins else { return .none }
                        
                        if state.initialPassword == state.confirmingPassword {
                            let password = state.confirmingPassword
                            
                            return .run { send in
                                await send(.inner(.changeState(.confirmed)))
                                try? await Task.sleep(nanoseconds: 100_000_000)
                                
                                await send(.delegate(.navigateToRecoveryHint(password)))
                            }
                        } else {
                            return .run { send in
                                try? await Task.sleep(nanoseconds: 100_000_000)
                                
                                await send(.inner(.changeState(.mismatch)))
                                await send(.inner(.didResetForConfirmation))
                            }
                        }
                        
                    case .resetForConfirmation:
                        return .none
                    case .mismatch:
                        return .none
                    case .confirmed:
                        return .none
                    }
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .didResetForConfirmation:
                    state.checkFlag = .confirming
                    state.confirmingPassword = ""
                    return .none
                    
                case .changeState(let passwordState):
                    state.checkFlag = passwordState
                    return .none
                }
                
            case .scope(let scopeAction):
                switch scopeAction {
                case .delete(.presented(.delegate(.didAccept))):
                    state.delete = nil
                    
                    return .run { send in
                        passwordStore.delete()
                        passwordStore.deleteBiometrics()
                        try? userSetting.update(keyPath: \.isLocked, value: false)
                        try? userSetting.update(keyPath: \.lockHint, value: "")
                        
                        await send(.delegate(.popPassword))
                    }
                    
                case .delete:
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$delete, action: \.scope.delete) {
            Alert()
        }
    }
}
