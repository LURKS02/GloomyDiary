//
//  HistoryDelete.swift
//  GloomyDiary
//
//  Created by 디해 on 4/2/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct HistoryDelete {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    @Dependency(\.logger) var logger
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable {
        let sessionID: UUID
        let counselor: CounselingCharacter
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
        case didTapBackground
        case didTapRejectButton
        case didTapAcceptButton
        case dismiss(DismissState)
    }
    
    enum InnerAction: Equatable {
        case prepareForDismiss
    }
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case deleteHistory
    }
    
    enum DismissState {
        case normal
        case delete
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapBackground:
                    return .run { send in
                        logger.send(.tapped, "삭제 - 배경 클릭(아니요)", nil)
                        await send(.inner(.prepareForDismiss))
                    }
                    
                case .didTapRejectButton:
                    return .run { send in
                        logger.send(.tapped, "삭제 - 아니요", nil)
                        await send(.inner(.prepareForDismiss))
                    }
                    
                case .didTapAcceptButton:
                    let sessionID = state.sessionID
                    state.flag = .delete
                    
                    return .run { send in
                        logger.send(.tapped, "삭제 - 예", nil)
                        try await counselingSessionRepository.delete(id: sessionID)
                        await send(.inner(.prepareForDismiss))
                    }
                    
                case .dismiss(let dismissState):
                    switch dismissState {
                    case .normal:
                        guard state.flag == .normal else { return .none }
                        return .run { _ in
                            await dismiss()
                        }
                        
                    case .delete:
                        guard state.flag == .delete else { return .none }
                        return .run { send in
                            await send(.delegate(.deleteHistory))
                            await dismiss()
                        }
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
