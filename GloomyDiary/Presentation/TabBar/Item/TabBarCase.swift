//
//  TabBarImageSet.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit

enum TabBarCase: String {
    case home
    case history
    case diary
}

extension TabBarCase {
    var viewController: UIViewController {
        switch self {
        case .home:
            return HomeViewController()
            
        case .history:
            return HistoryViewController()
            
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
