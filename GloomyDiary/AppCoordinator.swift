//
//  AppCoordinator.swift
//  GloomyDiary
//
//  Created by 디해 on 11/20/24.
//

import UIKit
import ComposableArchitecture

final class AppCoordinator {
    @Dependency(\.userSetting) var userSetting
    
    private let window: UIWindow
    
    private var isFirstProcess: Bool {
        userSetting.get(keyPath: \.isFirstProcess)
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        #if SCROLL_TEST
        showScrollSetting()
        
        #else
        if isFirstProcess {
            showTutorial()
        } else {
            showHome()
        }
        #endif
    }
}

private extension AppCoordinator {
    func showTutorial() {
        let tabs: [FloatingTabBarItemCase] = [.home(true), .history, .setting]
        let mainViewController = FloatingTabBarController(tabBarItems: tabs.map { $0.value })
        mainViewController.hideTabBar()
        
        if let homeVC = mainViewController.selectedViewController as? HomeViewController {
            let coveringView = UIView().then {
                $0.backgroundColor = AppColor.Background.main.color
                $0.frame = UIScreen.main.bounds
            }
            homeVC.contentView.addSubview(coveringView)
            homeVC.coveringView = coveringView
        }
        
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
}
    
private extension AppCoordinator {
    func showHome() {
        let tabs: [FloatingTabBarItemCase] = [.home(false), .history, .setting]
        let mainViewController = FloatingTabBarController(tabBarItems: tabs.map { $0.value })
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
    
    #if SCROLL_TEST
    func showScrollSetting() {
        let tabs: [FloatingTabBarItemCase] = [.home(false), .history, .setting]
        let mainViewController = FloatingTabBarController(tabBarItems: tabs.map { $0.value })
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
        
        let debugReadyViewController = DebugReadyViewController()
        debugReadyViewController.modalPresentationStyle = .overFullScreen
        mainViewController.present(debugReadyViewController, animated: false)
        
        Task {
            let testEnvironmentManager = TestEnvironmentManager()
            testEnvironmentManager.delegate = debugReadyViewController
            await testEnvironmentManager.prepareEnvironment()
        }
    }
    #endif
}
