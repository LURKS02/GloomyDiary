//
//  Welcome.swift
//  GloomyDiary
//
//  Created by 디해 on 2/17/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Welcome {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapGhost
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case navigateToGuide
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapGhost:
                    logger.send(.tapped, "튜토리얼: 유령을 클릭했습니다.", nil)
                    
                    return .run { send in
                        await send(.delegate(.navigateToGuide))
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
