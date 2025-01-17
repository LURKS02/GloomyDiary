//
//  AppDelegate.swift
//  GloomyDiary
//
//  Created by 디해 on 8/1/24.
//

import UIKit
import FirebaseCore
import AmplitudeSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if !DEBUG
        FirebaseApp.configure()
        #endif
        
        ArrayTransformer.register()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

