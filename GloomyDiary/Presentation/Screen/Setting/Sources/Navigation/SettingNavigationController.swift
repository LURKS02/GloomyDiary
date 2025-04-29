//
//  SettingNavigationController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/21/25.
//

import ComposableArchitecture
import UIKit

final class SettingNavigationController: NavigationStackController {
    private var store: StoreOf<SettingNavigation>!
    
    convenience init(store: StoreOf<SettingNavigation>) {
        @UIBindable var store = store
        
        self.init(path: $store.scope(state: \.path, action: \.path)) {
            let vc = SettingViewController(store: store.scope(state: \.setting, action: \.setting))
            return vc
        } destination: { store in
            switch store.case {
            case .theme(let store):
                ThemeViewController(store: store)
            case .password(let store):
                PasswordSettingViewController(store: store)
            case .recoveryHint(let store):
                RecoveryHintViewController(store: store)
            }
        }
        
        self.store = store
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.isEnabled = true
        self.interactivePopGestureRecognizer?.delegate = self
    }
}

extension SettingNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
