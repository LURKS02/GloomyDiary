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
    
    private var isShowing: Bool = false
    
    func presentLockScreenIfNeeded(isDismissable: Bool, onSuccess: (() -> Void)? = nil) {
        guard !isShowing,
              userSetting.get(keyPath: \.isLocked) == true else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else { return }
        
        let lockViewController = LockViewController(
            isDismissable: isDismissable,
            store: .init(initialState: .init(), reducer: { PasswordLock() } )
        )
        lockViewController.modalPresentationStyle = .fullScreen
        lockViewController.onSuccess = onSuccess
        lockViewController.onDismiss = {
            self.isShowing = false
        }
        
        rootViewController.present(lockViewController, animated: true) {
            self.isShowing = true
        }
    }
}
