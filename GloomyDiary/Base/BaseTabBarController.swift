//
//  BaseTabBarController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/9/24.
//

import UIKit

class BaseTabBarController: UITabBarController {
    var cases: [TabBarCase]
    
    var items: [UITabBarItem] {
        cases.map { $0.viewController.tabBarItem }
    }
    
    var backgroundColor: UIColor = .white {
        didSet {
            let appearance = self.tabBar.standardAppearance
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
            
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    var font: UIFont = .systemFont(ofSize: 15) {
        didSet {
            let appearance = self.tabBar.standardAppearance
            var selectedAttributes = appearance.stackedLayoutAppearance.selected.titleTextAttributes
            var normalAttributes = appearance.stackedLayoutAppearance.normal.titleTextAttributes
            
            selectedAttributes[.font] = font
            normalAttributes[.font] = font
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    var selectedFontColor: UIColor = .blue {
        didSet {
            let appearance = self.tabBar.standardAppearance
            var selectedAttributes = appearance.stackedLayoutAppearance.selected.titleTextAttributes
            
            selectedAttributes[.foregroundColor] = selectedFontColor
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    var normalFontColor: UIColor = .black {
        didSet {
            let appearance = self.tabBar.standardAppearance
            var normalAttributes = appearance.stackedLayoutAppearance.normal.titleTextAttributes
            
            normalAttributes[.foregroundColor] = selectedFontColor
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    var imageInsets: UIEdgeInsets = .zero {
        didSet {
            self.viewControllers?.forEach {
                $0.tabBarItem.imageInsets = imageInsets
            }
        }
    }
    
    init(_ cases: [TabBarCase]) {
        self.cases = cases
        
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.viewControllers = cases.map { tabBarCase in
            tabBarCase.viewController.then {
                $0.tabBarItem.title = tabBarCase.title
                $0.tabBarItem.image = tabBarCase.normalImage.withRenderingMode(.alwaysOriginal)
                $0.tabBarItem.selectedImage = tabBarCase.selectedImage.withRenderingMode(.alwaysOriginal)
            }
        }
    }
}

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let targetIndex = tabBarController.viewControllers?.firstIndex(where: { $0 == viewController }) {
            UIView.performWithoutAnimation {
                tabBarController.selectedIndex = targetIndex
            }
        }
        return false
    }
}
