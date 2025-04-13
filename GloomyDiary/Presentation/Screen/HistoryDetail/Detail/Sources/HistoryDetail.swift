//
//  HistoryDetail.swift
//  GloomyDiary
//
//  Created by 디해 on 12/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HistoryDetail {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        
        let session: Session
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case viewDidLoad
        case didTapMenuButton
        case didTapBackButton
    }
    enum InnerAction: Equatable {
    }
    
    @CasePathable
    enum ScopeAction: Equatable {
        case destination(PresentationAction<Destination.Action>)
    }
    
    enum DelegateAction: Equatable {
        case deleteSession(UUID)
        case didNavigateToDetail
    }
    
    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .viewDidLoad:
                    return .run { send in
                        await send(.delegate(.didNavigateToDetail))
                    }
                    
                case .didTapMenuButton:
                    state.destination = .menu(.init())
                    return .none
                    
                case .didTapBackButton:
                    return .run { send in
                        await dismiss()
                    }
                }
                
            case .scope(.destination(.presented(.menu(.delegate(.didTapDelete))))):
                state.destination = .delete(
                    .init(
                        sessionID: state.session.id,
                        counselor: state.session.counselor
                    )
                )
                return .none
                
            case .scope(.destination(.presented(.menu(.delegate(.didTapShare))))):
                state.destination = .activity
                return .none
                
            case .scope(.destination(.presented(.delete(.delegate(.deleteHistory))))):
                let sessionID = state.session.id
                
                return .run { send in
                    await send(.delegate(.deleteSession(sessionID)))
                    await dismiss()
                }
                
            case .scope(.destination(.dismiss)):
                state.destination = nil
                return .none
                
            case .scope:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.scope.destination)
    }
}

extension HistoryDetail {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case menu(HistoryMenu)
        case delete(HistoryDelete)
        case activity
    }
}
