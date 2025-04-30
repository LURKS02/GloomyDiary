//
//  SceneDelegate.swift
//  GloomyDiary
//
//  Created by 디해 on 8/1/24.
//

import UIKit
import ComposableArchitecture
import Dependencies

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    private var hasShownLockScreen = false
    
    @Dependency(\.logger) var logger
    @Dependency(\.userSetting) var userSetting

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        LocalNotificationService.shared.scheduleDailyNotifications(for: 60)
        PasswordLockManager.shared.toggleMaskingWindow(false)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        PasswordLockManager.shared.toggleMaskingWindow(true)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        PasswordLockManager.shared.presentLockScreenIfNeeded(isDismissable: false)
        PasswordLockManager.shared.toggleMaskingWindow(false)
        hasShownLockScreen = true
        
        self.logger.send(.app, "포그라운드 진입", nil)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        PasswordLockManager.shared.toggleMaskingWindow(true)
        self.logger.send(.app, "백그라운드 진입", nil)
    }
}
