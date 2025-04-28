//
//  HistoryNavigation.swift
//  GloomyDiary
//
//  Created by 디해 on 4/3/25.
//

import ComposableArchitecture
import UIKit

@Reducer
struct HistoryNavigation {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var history = History.State()
    }
    
    @CasePathable
    enum Action: Equatable {
        case path(StackActionOf<Path>)
        case history(History.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.history, action: \.history) {
            History()
        }
        
        Reduce { state, action in
            switch action {
            case .history(.delegate(.navigateToDetail(let session))):
                logger.send(.tapped, "상세: 셀을 눌러 다음 화면으로 이동합니다.", nil)
                state.path.append(.detail(.init(session: session)))
                return .none
                
            case .history:
                return .none
                
            case .path(.element(id: _, action: .detail(.delegate(.deleteSession(let sessionID))))):
                return .run { send in
                    await send(.history(.scope(.didRemoveSession(sessionID))))
                }
                
            case .path(.element(id: _, action: .detail(.delegate(.didNavigateToDetail)))):
                return .run { send in
                    await send(.history(.scope(.didNavigateToDetail)))
                }
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension HistoryNavigation {
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case detail(HistoryDetail)
    }
}
