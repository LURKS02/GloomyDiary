//
//  CircularTabBarItem.swift
//  GloomyDiary
//
//  Created by 디해 on 10/25/24.
//

import UIKit
import ComposableArchitecture

enum CircularTabBarItem: String {
    case home
    case history
}

extension CircularTabBarItem {
    var viewController: UIViewController {
        switch self {
        case .home:
            let store = Store(initialState: Home.State()) {
                Home()
            }
            return HomeViewController(store: store)
            
        case .history:
            let store = Store(initialState: History.State()) { History() }
            return NavigationController(rootViewController: HistoryViewController(store: store))
        }
    }
}

extension CircularTabBarItem {
    var title: String {
        switch self {
        case .home:
            "홈"
        case .history:
            "히스토리"
        }
    }
    
    var normalImage: UIImage {
        UIImage(named: self.rawValue + "_unselected")!
    }
    
    var selectedImage: UIImage {
        UIImage(named: self.rawValue + "_selected")!
    }
}
