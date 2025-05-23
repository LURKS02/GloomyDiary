//
//  ChoosingTheme.swift
//  GloomyDiary
//
//  Created by 디해 on 4/21/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ChoosingTheme {
    @Dependency(\.userSetting) var userSetting
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var theme: AppearanceMode
        var page: Int
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapMode(Int)
        case didTapBackButton
        case didTapSelectButton
        case didScrollToPage(Int)
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case themeChanged
    }
    
    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                    
                case .didTapMode(let index):
                    state.theme = AppearanceMode.allCases[index]
                    state.page = index
                    return .none
                    
                case .didScrollToPage(let page):
                    state.theme = AppearanceMode.allCases[page]
                    state.page = page
                    return .none
                    
                case .didTapSelectButton:
                    let theme = state.theme
                    return .run { send in
                        try userSetting.update(keyPath: \.appearanceMode, value: theme)
                        AppEnvironment.appearanceMode = theme
                        
                        NotificationCenter.default.post(name: .themeShouldRefreshWithoutAnimation, object: nil)
                        
                        await send(.delegate(.themeChanged))
                        await dismiss()
                    }
                    
                case .didTapBackButton:
                    return .run { _ in
                        await dismiss()
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

extension Notification.Name {
    static let themeShouldRefreshWithoutAnimation = Notification.Name("themeShouldRefreshWithoutAnimation")
    static let themeShouldRefresh = Notification.Name("themeShouldRefresh")
}
