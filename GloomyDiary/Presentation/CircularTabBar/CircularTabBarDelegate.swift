//
//  CircularTabBarDelegate.swift
//  GloomyDiary
//
//  Created by 디해 on 1/8/25.
//

import UIKit

protocol CircularTabBarDelegate: UIViewController {
    func tabDidDisappear()
    func tabWillAppear()
}

extension UIViewController {
    var tabBarDelegate: CircularTabBarDelegate? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController as? CircularTabBarDelegate
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController as? CircularTabBarDelegate
        } else {
            return self as? CircularTabBarDelegate
        }
    }
}
