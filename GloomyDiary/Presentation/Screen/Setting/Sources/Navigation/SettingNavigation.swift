//
//  SettingNavigation.swift
//  GloomyDiary
//
//  Created by 디해 on 4/21/25.
//

import ComposableArchitecture
import UIKit

@Reducer
struct SettingNavigation {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var setting = Setting.State()
    }
    
    @CasePathable
    enum Action: Equatable {
        case path(StackActionOf<Path>)
        case setting(Setting.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.setting, action: \.setting) {
            Setting()
        }
        
        Reduce { state, action in
            switch action {
            case .setting(.delegate(.navigateToMenu(let settingMenu))):
                switch settingMenu {
                case .version:
                    return .none
                    
                case .theme:
                    logger.send(.tapped, "설정: \(settingMenu.title) 메뉴를 눌러 이동합니다.", nil)
                    guard let index = AppearanceMode.allCases.firstIndex(of: AppEnvironment.appearanceMode) else { return .none }
                    state.path.append(.theme(.init(theme: AppEnvironment.appearanceMode, page: index)))
                    return .none
                    
                case .password:
                    state.path.append(.password(.init()))
                    return .none
                }
                
            case .setting:
                return .none
                
            case .path(.element(id: _, action: .theme(.delegate(.themeChanged)))):
                return .run { send in
                    await send(.setting(.scope(.changeThemeIfNeeded)))
                }
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension SettingNavigation {
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case theme(ChoosingTheme)
        case password(Password)
    }
}
