//
//  Setting.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Setting {
    @ObservableState
    struct State: Equatable {
        var settingItems: [SettingMenuItem] = [
            SettingMenuItem(
                settingCase: .version,
                value: AppEnvironment.appVersion,
                isNavigatable: false
            ),
            SettingMenuItem(
                settingCase: .theme,
                value: AppEnvironment.appearanceMode.name,
                isNavigatable: true
            ),
            SettingMenuItem(
                settingCase: .password,
                value: "",
                isNavigatable: true
            )
        ]
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapMenuButton(SettingCase)
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {
        case changeThemeIfNeeded
    }
    
    enum DelegateAction: Equatable {
        case navigateToMenu(SettingCase)
    }
    
    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapMenuButton(let settingCase):
                    return .run { send in
                        await send(.delegate(.navigateToMenu(settingCase)))
                    }
                }
                
            case .scope(let scopeAction):
                switch scopeAction {
                    case .changeThemeIfNeeded:
                        let settingItems = state.settingItems
                    
                        state.settingItems = settingItems.map { item in
                            if item.settingCase == .theme {
                                return SettingMenuItem(
                                    settingCase: item.settingCase,
                                    value: AppEnvironment.appearanceMode.name,
                                    isNavigatable: item.isNavigatable
                                )
                            } else {
                                return item
                            }
                        }
                    
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
