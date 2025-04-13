//
//  CounselResult.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CounselResult {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        
        let counselor: CounselingCharacter
        var session: Session?
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case updateResponse(Session)
        case didTapCopyButton
        case didTapHomeButton
        case didTapShareButton
        case didTapBackButton
    }
    
    enum InnerAction: Equatable {
    }
    
    @CasePathable
    enum ScopeAction: Equatable {
        case destination(PresentationAction<Destination.Action>)
    }
    
    enum DelegateAction: Equatable {
        case dismiss
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .updateResponse(let session):
                    state.session = session
                    return .none
                    
                case .didTapCopyButton:
                    logger.send(.tapped, "클립보드 복사 버튼", nil)
                    return .none
                    
                case .didTapHomeButton:
                    logger.send(.tapped, "홈 버튼", nil)
                    return .run { send in
                        await send(.delegate(.dismiss))
                    }
                    
                case .didTapShareButton:
                    logger.send(.tapped, "공유 버튼", nil)
                    state.destination = .activity
                    return .none
                    
                case .didTapBackButton:
                    logger.send(.tapped, "네트워크 에러 - 뒤로 가기 버튼", nil)
                    return .run { send in
                        await dismiss()
                    }
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
    }
}

extension CounselResult {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case activity
    }
}
