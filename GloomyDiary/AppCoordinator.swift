//
//  AppCoordinator.swift
//  GloomyDiary
//
//  Created by 디해 on 11/20/24.
//

import UIKit
import ComposableArchitecture

final class AppCoordinator {
    var window: UIWindow
    private let isFirstProcess: Bool
    
    init(window: UIWindow) {
        @Dependency(\.userSettingRepository) var userSettingRepository
        
        self.window = window
        self.isFirstProcess = userSettingRepository.get(keyPath: \.isFirstProcess)
    }
    
    func start() {
        if isFirstProcess {
            showCounselView()
        } else {
            showMainView()
        }
    }
}

private extension AppCoordinator {
    func showCounselView() {
        let mainViewController = CircularTabBarController(tabBarItems: [.home, .history])
        mainViewController.hideCircularTabBar()
        mainViewController.view.alpha = 0.0
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
        
        let welcomeViewController = WelcomeViewController()
        
        let navigationViewController = UINavigationController(rootViewController: welcomeViewController)
        navigationViewController.modalPresentationStyle = .custom
        guard let selectedViewController = mainViewController.selectedViewController,
        let animationDelegateViewController =  selectedViewController as? UIViewControllerTransitioningDelegate else { return }
        
        navigationViewController.transitioningDelegate = animationDelegateViewController
        selectedViewController.present(navigationViewController, animated: false)
        mainViewController.view.alpha = 1.0
    }
    
    func showMainView() {
        let mainViewController = CircularTabBarController(tabBarItems: [.home, .history])
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
}
