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
    
    @ObservableState
    struct State: Equatable {
        let session: Session
    }
    
    enum Action {
        case deleteSession(id: UUID)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .deleteSession(let id):
                return .none
//                counselingSessionRepository.delete(id: id)
            }
        }
    }
}
