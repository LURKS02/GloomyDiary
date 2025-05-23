//
//  FloatingTabBarItemCase.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import ComposableArchitecture
import UIKit

enum FloatingTabBarItemCase {
    case home(Bool)
    case history
    case setting
    
    var value: FloatingTabBarItem {
        switch self {
        case .home(let tutorial):
            let store: Store<Home.State, Home.Action> = tutorial ? Store(initialState: Home.State(destination: .tutorial(.init()))) { Home() } : Store(initialState: Home.State()) { Home() }
            
            let viewController = HomeViewController(store: store)
            
            return FloatingTabBarItem(
                viewController: viewController,
                title: "홈",
                normalImage: AppImage.TabBar.home.image(isSelected: false),
                selectedImage: AppImage.TabBar.home.image(isSelected: true)
            )
            
        case .history:
            let store = Store(initialState: HistoryNavigation.State()) { HistoryNavigation() }
            let viewController = HistoryNavigationController(store: store)
            
            return FloatingTabBarItem(
                viewController: viewController,
                title: "히스토리",
                normalImage: AppImage.TabBar.history.image(isSelected: false),
                selectedImage: AppImage.TabBar.history.image(isSelected: true)
            )
            
        case .setting:
            let store = Store(initialState: SettingNavigation.State()) { SettingNavigation() }
            let viewController = SettingNavigationController(store: store)
            
            return FloatingTabBarItem(
                viewController: viewController,
                title: "설정",
                normalImage: AppImage.TabBar.setting.image(isSelected: false),
                selectedImage: AppImage.TabBar.setting.image(isSelected: true)
            )
        }
    }
}
