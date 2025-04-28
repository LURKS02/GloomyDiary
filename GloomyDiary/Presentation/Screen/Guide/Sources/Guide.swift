//
//  Guide.swift
//  GloomyDiary
//
//  Created by 디해 on 2/17/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Guide {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var animationCount: Int = 0
        var animationLimit: Int = 4
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapBackground
    }
    
    enum InnerAction: Equatable {
        case animationDidEnd
    }
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case navigateToStartCounsel
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapBackground:
                    state.animationCount += 1
                    logger.send(.tapped, "튜토리얼: 화면을 클릭했습니다.", ["애니메이션 횟수": state.animationCount])
                    
                    if state.animationCount == state.animationLimit {
                        return .send(.inner(.animationDidEnd))
                    }
                    
                    return .none
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .animationDidEnd:
                    return .run { send in
                        await send(.delegate(.navigateToStartCounsel))
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
