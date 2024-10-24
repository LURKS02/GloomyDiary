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
    @ObservableState
    struct State: Equatable {
        var counselingSessionDTOs: [CounselingSessionDTO] = []
    }
    
    enum Action {
        case refresh
        case counselingSessionDTOsResponse([CounselingSessionDTO])
    }
    
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                return .run { send in
                    let sessions = try await counselingSessionRepository.fetch()
                    await send(.counselingSessionDTOsResponse(sessions))
                }
                
            case let .counselingSessionDTOsResponse(sessions):
                state.counselingSessionDTOs = sessions
                return .none
            }
        }
    }
}
