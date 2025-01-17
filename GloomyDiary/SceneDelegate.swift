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
    @Dependency(\.logger) var logger

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
        LocalNotification.shared.scheduleDailyNotifications(for: 60)
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        self.logger.send(.app, "포그라운드 진입", nil)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        self.logger.send(.app, "백그라운드 진입", nil)
    }


}

extension UIApplication {
    var safeAreaTopInset: CGFloat? {
        guard let keyWindow = connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow) else { return nil }
        
        return keyWindow.safeAreaInsets.top
    }
}
