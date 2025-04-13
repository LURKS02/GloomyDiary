//
//  HistoryMenu.swift
//  GloomyDiary
//
//  Created by 디해 on 4/2/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct HistoryMenu {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var prepareForDismiss: Bool = false
        var flag: DismissState = .normal
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapMenuButton(MenuItem)
        case didTapBackground
        case dismiss(DismissState)
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case didTapDelete
        case didTapShare
    }
    
    enum DismissState {
        case normal
        case sharing
        case delete
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapMenuButton(let item):
                    switch item {
                    case .delete:
                        state.prepareForDismiss = true
                        state.flag = .delete
                        return .none
                        
                    case .share:
                        state.prepareForDismiss = true
                        state.flag = .sharing
                        return .none
                    }
                    
                case .didTapBackground:
                    state.prepareForDismiss = true
                    return .none
                    
                case .dismiss(let dismissState):
                    switch dismissState {
                    case .normal:
                        guard state.flag == .normal else { return .none }
                        
                        return .run { _ in
                            await dismiss()
                        }
                        
                    case .sharing:
                        guard state.flag == .sharing else { return .none }
                        
                        return .run { send in
                            logger.send(.tapped, "상세 - 공유하기", nil)
                            await send(.delegate(.didTapShare))
                            await dismiss()
                        }
                        
                    case .delete:
                        guard state.flag == .delete else { return .none }
                        
                        return .run { send in
                            logger.send(.tapped, "상세 - 삭제하기", nil)
                            await send(.delegate(.didTapDelete))
                            await dismiss()
                        }
                    }
                }
                
            case .scope:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
