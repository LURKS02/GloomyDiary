//
//  PasswordLockManager.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import UIKit

final class PasswordLockManager {
    static let shared = PasswordLockManager()
    
    private init() { }
    
    private var isShowing: Bool = false
    
    func presentLockScreenIfNeeded() {
        guard !isShowing else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else { return }
        
        let lockViewController = LockViewController(store: .init(initialState: .init(), reducer: { PasswordLock() } ))
        lockViewController.modalPresentationStyle = .fullScreen
        
        rootViewController.present(lockViewController, animated: true) {
            self.isShowing = true
        }
    }
}
