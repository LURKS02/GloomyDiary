//
//  CircularTabBarItemCase.swift
//  GloomyDiary
//
//  Created by 디해 on 2/2/25.
//

import ComposableArchitecture
import UIKit

enum CircularTabBarItemCase: CaseIterable {
    case home
    case history
    
    var value: CircularTabBarItem {
        switch self {
        case .home:
            let store = Store(initialState: Home.State()) { Home() }
            let viewController = HomeViewController(store: store)
            
            return CircularTabBarItem(
                viewController: viewController,
                title: "홈",
                normalImage: UIImage(named: "home_unselected")!,
                selectedImage: UIImage(named: "home_selected")!
            )
            
        case .history:
            let store = Store(initialState: HistoryNavigation.State()) { HistoryNavigation() }
            let viewController = HistoryNavigationController(store: store)
            
            return CircularTabBarItem(
                viewController: viewController,
                title: "히스토리",
                normalImage: UIImage(named: "history_unselected")!,
                selectedImage: UIImage(named: "history_selected")!
            )
        }
    }
}
