//
//  MockThemeScheduler.swift
//  GloomyDiary
//
//  Created by 디해 on 4/24/25.
//

import Foundation

final class MockThemeScheduler: ThemeScheduling {
    
    private var timer: Timer?
    
    private var isDebugNightMode: Bool = true
    
    var resolvedDefault: AppearanceMode {
        isDebugNightMode ? .dark : .light
    }
    
    func start() {
        guard AppEnvironment.appearanceMode == .default else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { [weak self] _ in
            self?.isDebugNightMode.toggle()
            NotificationCenter.default.post(name: .themeShouldRefresh, object: nil)
        })
    }
}
