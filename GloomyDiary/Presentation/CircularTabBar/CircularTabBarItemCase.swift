////
////  CircularTabBarItemCase.swift
////  GloomyDiary
////
////  Created by 디해 on 2/2/25.
////
//
//import ComposableArchitecture
//import UIKit
//
//enum CircularTabBarItemCase {
//    case home(Bool)
//    case history
//    case setting
//    
//    var value: CircularTabBarItem {
//        switch self {
//        case .home(let tutorial):
//            let store: Store<Home.State, Home.Action> = tutorial ? Store(initialState: Home.State(destination: .tutorial(.init()))) { Home() } : Store(initialState: Home.State()) { Home() }
//            
//            let viewController = HomeViewController(store: store)
//            
//            return CircularTabBarItem(
//                viewController: viewController,
//                title: "홈",
//                normalImage: AppImage.TabBar.home.image(isSelected: false),
//                selectedImage: AppImage.TabBar.home.image(isSelected: true)
//            )
//            
//        case .history:
//            let store = Store(initialState: HistoryNavigation.State()) { HistoryNavigation() }
//            let viewController = HistoryNavigationController(store: store)
//            
//            return CircularTabBarItem(
//                viewController: viewController,
//                title: "히스토리",
//                normalImage: AppImage.TabBar.history.image(isSelected: false),
//                selectedImage: AppImage.TabBar.history.image(isSelected: true)
//            )
//            
//        case .setting:
//            let store = Store(initialState: Setting.State()) { Setting() }
//            let viewController = SettingViewController(store: store)
//            
//            return CircularTabBarItem(
//                viewController: viewController,
//                title: "설정",
//                normalImage: AppImage.TabBar.setting.image(isSelected: false),
//                selectedImage: AppImage.TabBar.setting.image(isSelected: true)
//            )
//        }
//    }
//}
