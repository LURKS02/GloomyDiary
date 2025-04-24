//
//  ThemeScheduler.swift
//  GloomyDiary
//
//  Created by 디해 on 4/24/25.
//

import Foundation

final class ThemeScheduler: ThemeScheduling {
    
    private var timer: Timer?
    
    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 18 || hour < 6
    }
    
    var resolvedDefault: AppearanceMode {
        return isNightTime ? .dark : .light
    }
    
    func start() {
        guard AppEnvironment.appearanceMode == .default else { return }
        
        applyThemeForCurrentTime()
        scheduleNextThemeChange()
    }
    
    private func scheduleNextThemeChange() {
        timer?.invalidate()
        
        let now = Date()
        let calendar = Calendar.current
        
        let today6AM = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: now)!
        let today6PM = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now)!
        
        let nextTriggerTime: Date
        if now < today6AM {
            nextTriggerTime = today6AM
        } else if now < today6PM {
            nextTriggerTime = today6PM
        } else {
            nextTriggerTime = calendar.date(byAdding: .day, value: 1, to: today6AM)!
        }
        
        let timeInterval = nextTriggerTime.timeIntervalSince(now)
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.applyThemeForCurrentTime()
            self?.scheduleNextThemeChange()
        }
    }
    
    private func applyThemeForCurrentTime() {
        NotificationCenter.default.post(name: .themeShouldRefresh, object: nil)
    }
}
