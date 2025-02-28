//
//  History.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct History {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    
    @ObservableState
    struct State: Equatable {
        let pageSize: Int = 10
        var page: Int = 0
        var sessions: [Session] = []
        var isLoading: Bool = false
        var isEndOfPage: Bool = false
    }
    
    enum Action {
        case refresh
        case loadNextPage
        case SessionsResponse([Session])
        case unload
        case stopFetchingPages
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                state.isLoading = true
                state.page = 0
                return .run { [state] send in
                    let sessions = try await counselingSessionRepository.fetch(pageNumber: 0, pageSize: state.pageSize)
                    await send(.SessionsResponse(sessions))
                }
                
            case .loadNextPage:
                state.isLoading = true
                state.page += 1
                return .run { [state] send in
                    let sessions = try await counselingSessionRepository.fetch(pageNumber: state.page, pageSize: state.pageSize)
                    guard sessions.count > 0 else {
                        return await send(.stopFetchingPages)
                    }
                        
                    await send(.SessionsResponse(state.sessions + sessions))
                }
                
            case let .SessionsResponse(sessions):
                state.isLoading = false
                
                state.sessions = sessions
                return .none
                
            case .unload:
                state.page = 0
                state.sessions = []
                return .none
                
            case .stopFetchingPages:
                state.isEndOfPage = true
                return .none
            }
        }
    }
}
