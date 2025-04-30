//
//  Alert.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Alert {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var prepareForDismiss: Bool = false
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapRejectButton
        case didTapAcceptButton
        case dismiss
    }
    
    enum InnerAction: Equatable {
        case prepareForDismiss
    }
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case didAccept
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapAcceptButton:
                    return .run { send in
                        logger.send(.tapped, "Alert - 예", nil)
                        await send(.inner(.prepareForDismiss))
                        await send(.delegate(.didAccept))
                    }
                    
                case .didTapRejectButton:
                    return .run { send in
                        logger.send(.tapped, "Alert - 아니오", nil)
                        await send(.inner(.prepareForDismiss))
                    }
                    
                case .dismiss:
                    return .run { _ in
                        await dismiss()
                    }
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .prepareForDismiss:
                    state.prepareForDismiss = true
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
