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
        let tabs = CircularTabBarItemCase.allCases
        let mainViewController = CircularTabBarController(tabBarItems: tabs.map { $0.value })
        mainViewController.hideCircularTabBar()
        
        guard let originView = mainViewController.view else { return }
        
        let coveringView = createCoveringView(for: originView)
        originView.addSubview(coveringView)
        
        configureWindow(with: mainViewController)
        
        let welcomeViewController = createWelcomeViewController()
        
        guard let selectedViewController = mainViewController.selectedViewController else { return }
        configureCustomTransition(for: welcomeViewController, in: selectedViewController, coveringView: coveringView)
    }
    
    private func createCoveringView(for originView: UIView) -> UIView {
        return UIView().then {
            $0.backgroundColor = AppColor.Background.main.color
            $0.frame = originView.bounds
        }
    }
    
    private func configureWindow(with rootViewController: UIViewController) {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    private func createWelcomeViewController() -> UINavigationController {
        let navigationController = TutorialNavigationController(store: .init(initialState: .init(), reducer: {
            TutorialNavigation()
        }))
        navigationController.modalPresentationStyle = .custom
        return navigationController
    }
    
    private func configureCustomTransition(
        for navigationController: UINavigationController,
        in viewController: UIViewController,
        coveringView: UIView
    ) {
        guard let delegateViewController = viewController as? UIViewControllerTransitioningDelegate else { return }

        navigationController.transitioningDelegate = delegateViewController
        viewController.present(navigationController, animated: false) {
            coveringView.removeFromSuperview()
        }
    }
}
    
private extension AppCoordinator {
    func showHome() {
        let tabs = CircularTabBarItemCase.allCases
        let mainViewController = CircularTabBarController(tabBarItems: tabs.map { $0.value })
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
    
    #if SCROLL_TEST
    func showScrollSetting() {
        let tabs = CircularTabBarItemCase.allCases
        let mainViewController = CircularTabBarController(tabBarItems: tabs.map { $0.value })
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
