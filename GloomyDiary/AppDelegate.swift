//
//  AppDelegate.swift
//  GloomyDiary
//
//  Created by 디해 on 8/1/24.
//

import AmplitudeSwift
import Dependencies
import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    @Dependency(\.themeScheduler) var themeScheduler
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if !DEBUG
        FirebaseApp.configure()
        #endif
        
        ArrayTransformer.register()
        startObservingAppIcon()
        themeScheduler.start()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .themeShouldRefresh, object: nil)
        themeScheduler.start()
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func startObservingAppIcon() {
        updateAppIcon()
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateAppIcon()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefreshWithoutAnimation)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.themeScheduler.start()
                self?.updateAppIcon()
            }
            .store(in: &cancellables)
    }
}

extension AppDelegate {
    func updateAppIcon() {
        let mode = AppEnvironment.appearanceMode
        
        let targetIcon: String
        switch mode {
        case .default:
            let resolvedMode = themeScheduler.resolvedDefault
            switch resolvedMode {
            case .dark:
                targetIcon = "DarkAppIcon"
            case .light:
                targetIcon = "LightAppIcon"
            case .default:
                targetIcon = "AppIcon"
            }
        case .dark:
            targetIcon = "DarkAppIcon"
        case .light:
            targetIcon = "LightAppIcon"
        }
        
        setIconWithoutAlert(targetIcon)
    }
    
    func setIconWithoutAlert(_ appIconName: String) {
        if let alternateIconName = UIApplication.shared.alternateIconName,
           alternateIconName == appIconName { return }
        
        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
            typealias setAlternateIconName = @convention(c) (NSObject, Selector, NSString, @escaping (NSError) -> ()) -> ()
            let selectorString = "_setAlternateIconName:completionHandler:"
            let selector = NSSelectorFromString(selectorString)
            let imp = UIApplication.shared.method(for: selector)
            let method = unsafeBitCast(imp, to: setAlternateIconName.self)
            method(UIApplication.shared, selector, appIconName as NSString, { _ in })
        }
    }
}
