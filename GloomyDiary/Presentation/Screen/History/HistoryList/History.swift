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
        var counselingSessionDTOs: [CounselingSessionDTO] = []
        var isLoading: Bool = false
    }
    
    enum Action {
        case refresh
        case loadNextPage
        case counselingSessionDTOsResponse([CounselingSessionDTO])
        case unload
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                state.isLoading = true
                state.page = 0
                return .run { [state] send in
                    let sessions = try await counselingSessionRepository.fetch(pageNumber: 0, pageSize: state.pageSize)
                    await send(.counselingSessionDTOsResponse(sessions))
                }
                
            case .loadNextPage:
                if state.isLoading { return .none }
                state.isLoading = true
                state.page += 1
                return .run { [state] send in
                    let sessions = try await counselingSessionRepository.fetch(pageNumber: state.page, pageSize: state.pageSize)
                    await send(.counselingSessionDTOsResponse(state.counselingSessionDTOs + sessions))
                }
                
            case let .counselingSessionDTOsResponse(sessions):
                state.isLoading = false
                
                state.counselingSessionDTOs = sessions
                return .none
                
            case .unload:
                state.page = 0
                state.counselingSessionDTOs = []
                return .none
            }
        }
    }
}
