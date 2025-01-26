//
//  Extension+UIViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 1/24/25.
//

import UIKit

protocol ToTransitionable {
    var toTransitionComponent: UIView? { get }
    
    func completeTransition(duration: TimeInterval) async
}

protocol FromTransitionable {
    var fromTransitionComponent: UIView? { get }
    
    func prepareTransition(duration: TimeInterval) async
}

extension UIViewController {
    func visibleViewController() -> UIViewController {
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController() ?? tabBarController
        } else if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController() ?? navigationController
        } else {
            return self
        }
    }
    
    func toTransitionable() -> ToTransitionable? {
        let visibleViewController = self.visibleViewController()
        
        return visibleViewController as? ToTransitionable
    }
    
    func fromTransitionable() -> FromTransitionable? {
        let visibleViewController = self.visibleViewController()
        
        return visibleViewController as? FromTransitionable
    }
}
