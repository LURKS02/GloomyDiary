//
//  TabBarImageSet.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import ComposableArchitecture

enum TabBarCase: String {
    case home
    case history
    case diary
}

extension TabBarCase {
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
            
        case .diary:
            return DiaryViewController()
        }
    }
}

extension TabBarCase {
    var title: String {
        switch self {
        case .home:
            "홈"
        case .history:
            "히스토리"
        case .diary:
            "다이어리"
        }
    }
    
    var normalImage: UIImage {
        UIImage(named: self.rawValue + "_unselected")!
    }
    
    var selectedImage: UIImage {
        UIImage(named: self.rawValue + "_selected")!
    }
}
