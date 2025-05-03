//
//  PasswordLockManager.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import Dependencies
import UIKit

final class PasswordLockManager {
    
    @Dependency(\.userSetting) var userSetting
    
    static let shared = PasswordLockManager()
    
    private init() { }
    
    private var maskingWindow: UIWindow?
    
    private var isShowingLockScreen: Bool = false
    
    func toggleMaskingWindow(_ visible: Bool) {
        if visible && !isShowingLockScreen {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
            maskingWindow = UIWindow(windowScene: windowScene)
            maskingWindow?.rootViewController = AppSwitcherProtectionViewController()
            maskingWindow?.windowLevel = .alert + 1
            maskingWindow?.makeKeyAndVisible()
        } else {
            maskingWindow = nil
        }
    }
    
    func presentLockScreenIfNeeded(isDismissable: Bool, onSuccess: (() -> Void)? = nil) {
        guard !isShowingLockScreen,
              userSetting.get(keyPath: \.isLocked) == true else {
            onSuccess?()
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else { return }
        
        self.isShowingLockScreen = true
        
        let lockViewController = LockViewController(
            isDismissable: isDismissable,
            store: .init(initialState: .init(), reducer: { PasswordLock() } )
        )
        lockViewController.modalPresentationStyle = .fullScreen
        lockViewController.onSuccess = onSuccess
        lockViewController.onDismiss = {
            self.isShowingLockScreen = false
        }
        
        rootViewController.present(lockViewController, animated: true)
    }
}
