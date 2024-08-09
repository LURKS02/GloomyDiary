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
            self.tabBar.backgroundColor = backgroundColor
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
        }
    }
    
    var selectedFontColor: UIColor = .blue {
        didSet {
            let appearance = self.tabBar.standardAppearance
            var selectedAttributes = appearance.stackedLayoutAppearance.selected.titleTextAttributes
            
            selectedAttributes[.foregroundColor] = selectedFontColor
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            self.tabBar.standardAppearance = appearance
        }
    }
    
    var normalFontColor: UIColor = .black {
        didSet {
            let appearance = self.tabBar.standardAppearance
            var normalAttributes = appearance.stackedLayoutAppearance.normal.titleTextAttributes
            
            normalAttributes[.foregroundColor] = selectedFontColor
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            self.tabBar.standardAppearance = appearance
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
