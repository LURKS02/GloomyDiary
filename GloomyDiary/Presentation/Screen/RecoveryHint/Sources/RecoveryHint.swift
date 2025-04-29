//
//  RecoveryHint.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct RecoveryHint {
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable {
        var hint: String = ""
        var warning: String = ""
        var isSendable: Bool = true
        let textLimit: Int = 20
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapBackButton
        case didTapNextButton
        case didEnterText(String)
    }
    
    enum InnerAction: Equatable {
        case updateTextValidation(String)
    }
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case dismissAll
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapBackButton:
                    return .run { send in
                        await send(.delegate(.dismissAll))
                    }
                    
                case .didTapNextButton:
                    return .run { _ in
                        await dismiss()
                    }
                    
                case .didEnterText(let text):
                    state.hint = text
                    
                    return .run { send in
                        await send(.inner(.updateTextValidation(text)))
                    }
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .updateTextValidation(let text):
                    if text.count > state.textLimit {
                        state.warning = "\(state.textLimit)자 이하로 작성해주세요."
                        state.isSendable = false
                    } else {
                        state.warning = ""
                        state.isSendable = true
                    }
                    
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
