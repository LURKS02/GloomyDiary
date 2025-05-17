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
        
        case unlockSuccessfully
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
                    return .run { send in
                        await MainActor.run {
                            PasswordLockManager.shared.presentLockScreenIfNeeded(isDismissable: true) {
                                Task {
                                    send(.unlockSuccessfully)
                                }
                            }
                        }
                    }
                }
                
            case .setting:
                return .none
                
            case .path(.element(id: _, action: .theme(.delegate(.themeChanged)))):
                return .run { send in
                    await send(.setting(.scope(.changeThemeIfNeeded)))
                }
                
            case .path(.element(id: _, action: .password(.delegate(.navigateToRecoveryHint(let password))))):
                state.path.removeLast()
                state.path.append(.recoveryHint(.init(password: password)))
                return .none
                
            case .path(.element(id: _, action: .password(.delegate(.popPassword)))):
                state.path.removeLast()
                return .none
                
            case .path(.element(id: _, action: .recoveryHint(.delegate(.dismissAll)))):
                state.path = StackState()
                return .none
                
            case .path:
                return .none
                
            case .unlockSuccessfully:
                state.path.append(.password(.init()))
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
        case recoveryHint(RecoveryHint)
    }
}
