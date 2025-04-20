//
//  SettingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import ComposableArchitecture
import UIKit

final class SettingViewController: BaseViewController<SettingView> {
    var store: StoreOf<Setting>
    
    init(store: StoreOf<Setting>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingViewController: ToTabSwitchAnimatable {
    func playTabAppearingAnimation(direction: TabBarDirection) async {
        
    }
}

extension SettingViewController: FromTabSwitchAnimatable {
    func playTabDisappearingAnimation(direction: TabBarDirection) async {
        
    }
}
