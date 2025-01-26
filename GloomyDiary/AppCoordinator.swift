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
        let mainViewController = CircularTabBarController(tabBarItems: [.home, .history])
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
            $0.backgroundColor = .background(.mainPurple)
            $0.frame = originView.bounds
        }
    }
    
    private func configureWindow(with rootViewController: UIViewController) {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    private func createWelcomeViewController() -> UINavigationController {
        let welcomeViewController = WelcomeViewController()
        let navigationController = UINavigationController(rootViewController: welcomeViewController)
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
        }
    }
}
    
private extension AppCoordinator {
    func showHome() {
        let mainViewController = CircularTabBarController(tabBarItems: [.home, .history])
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
    
    #if SCROLL_TEST
    func showScrollSetting() {
        showHome()
        
        let debugReadyViewController = DebugReadyViewController()
        debugReadyViewController.modalPresentationStyle = .overFullScreen
        Task {
            await MainActor.run {
                mainViewController.present(debugReadyViewController, animated: false)
            }
            let testEnvironmentManager = TestEnvironmentManager()
            await testEnvironmentManager.prepareEnvironment()
    
            await MainActor.run {
                debugReadyViewController.dismiss(animated: false)
            }
        }
    }
    #endif
}
