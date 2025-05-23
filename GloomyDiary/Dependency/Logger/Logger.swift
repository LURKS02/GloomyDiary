//
//  Logger.swift
//  GloomyDiary
//
//  Created by 디해 on 1/17/25.
//

import AmplitudeSwift
import Dependencies
import Foundation

struct Logger {
    static let amplitude: Amplitude? = {
        #if DEBUG
        return nil
        
        #else
        guard Bundle.main.isAppStore else { return nil }
        
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = dict["AmplitudeAPIKey"] as? String
        else { return nil }
        
        @Dependency(\.userSetting) var userSetting
        
        let amplitude = Amplitude(
            configuration: Configuration(
                apiKey: key,
                autocapture: [.appLifecycles]
            )
        )
        let userID = userSetting.get(keyPath: \.userID)
        print(">>> \(userID)")
        amplitude.setUserId(userId: userID.uuidString)
        
        return amplitude
        #endif
    }()
    
    var send: (
        _ type: LogType?,
        _ message: String,
        _ parameters: [String: Any]?
    ) -> Void
}

private enum LoggerKey: DependencyKey {
    static var liveValue = Logger(send: { (type, message, parameters) -> Void in
        #if DEBUG
        return
        
        #else
        var logMessage = message
        if let type {
            logMessage = "[\(type.keyword)] \(message) \(type.description)"
        }
        Logger.amplitude?.track(eventType: logMessage, eventProperties: parameters)
        return
        #endif
    })
    
    static var testValue = Logger(send: { (type, message, parameters) -> Void in
        return
    })
}

extension DependencyValues {
    var logger: Logger {
        get { self[LoggerKey.self] }
        set { self[LoggerKey.self] = newValue }
    }
}
