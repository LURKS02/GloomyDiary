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
    @Dependency(\.logger) var logger
    @Dependency(\.uuid) var uuid
    
    @ObservableState
    struct State: Equatable {
        let pageSize: Int = 10
        var page: Int = 0
        var items: [SessionItem] = []
        var isLoading: Bool = false
        var isEndOfPage: Bool = false
        var isNavigating: Bool = false
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case refresh
        case loadNextPage
        case unload
        case didSelectCell(Int)
    }
    
    enum InnerAction: Equatable {
        case stopFetchingPages
        case initializeSession([Session])
        case sessionResponse([Session])
    }
    
    enum ScopeAction: Equatable {
        case didRemoveSession(UUID)
        case didNavigateToDetail
    }
    
    enum DelegateAction: Equatable {
        case navigateToDetail(Session)
    }
    
    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .refresh:
                    state.isLoading = true
                    state.page = 0
                    state.isEndOfPage = false
                    return .run { [state] send in
                        let sessions = try await counselingSessionRepository.fetch(pageNumber: state.page, pageSize: state.pageSize)
                        await send(.inner(.initializeSession(sessions)))
                    }
                    
                case .loadNextPage:
                    guard !state.isLoading else { return .none }
                    
                    state.isLoading = true
                    state.page += 1
                    return .run { [state] send in
                        let sessions = try await counselingSessionRepository.fetch(pageNumber: state.page, pageSize: state.pageSize)
                        guard sessions.count > 0 else {
                            return await send(.inner(.stopFetchingPages))
                        }
                        
                        await send(.inner(.sessionResponse(sessions)))
                    }
                    
                case .didSelectCell(let index):
                    guard state.isNavigating == false else { return .none }
                    state.isNavigating = true
                    let item = state.items[index]
                    
                    return .run { send in
                        await send(.delegate(.navigateToDetail(item.session)))
                    }
                    
                case .unload:
                    state.page = 0
                    state.items = []
                    return .none
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .initializeSession(let sessions):
                    let newItems = sessions.map {
                        SessionItem(
                            uuid: uuid(),
                            session: $0
                        )
                    }
                    
                    state.items = newItems
                    return .none
                    
                case .sessionResponse(let sessions):
                    let newItems = sessions.map {
                        SessionItem(
                            uuid: uuid(),
                            session: $0
                        )
                    }
                    
                    state.isLoading = false
                    state.items += newItems
                    return .none
                    
                case .stopFetchingPages:
                    state.isEndOfPage = true
                    return .none
                }
                
            case .scope(let scopeAction):
                switch scopeAction {
                case .didRemoveSession(let id):
                    state.items = state.items.filter { $0.session.id != id }
                    return .none
                    
                case .didNavigateToDetail:
                    state.isNavigating = false
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
