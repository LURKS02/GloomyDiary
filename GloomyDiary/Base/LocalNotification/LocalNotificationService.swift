//
//  LocalNotification.swift
//  GloomyDiary
//
//  Created by 디해 on 11/28/24.
//

import Foundation
import UserNotifications
import Dependencies

final class LocalNotificationService {
    static let shared = LocalNotificationService()
    
    private init() { }
    
    private let identifier = "dailyNotification_"
    
    @Dependency(\.date.now) var now
    
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        guard let permission = try? await center.requestAuthorization(options: [.alert, .sound, .badge]) else { return false }
        return permission
    }
    
    func scheduleDailyNotifications(for days: Int) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for dayOffset in 1...days {
            guard let notificationDate = calculateNotificationDate(from: now, dayOffset: dayOffset) else { continue }
            
            let content = UNMutableNotificationContent()
            let notificationType = LocalNotificationType.randomElement()
            content.title = notificationType.title
            content.body = notificationType.body
            content.sound = .default
            
            let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            let identifier = "\(identifier)\(dayOffset)"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func calculateNotificationDate(from date: Date, dayOffset: Int) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.day = (components.day ?? 0) + dayOffset
        components.hour = 21
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)
    }
}
