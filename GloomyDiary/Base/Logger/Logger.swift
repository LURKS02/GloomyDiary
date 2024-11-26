//
//  Logger.swift
//  GloomyDiary
//
//  Created by 디해 on 11/26/24.
//

import Foundation
import AmplitudeSwift

final class Logger {
    fileprivate static let shared = Logger()
    
    private let amplitude: Amplitude? = {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = dict["AmplitudeAPIKey"] as? String else { return nil }
        
        return Amplitude(configuration: Configuration(apiKey: key, autocapture: []))
    }()
    
    
    func send(_ message: String, parameters: [String: Any]?) {
        amplitude?.track(eventType: message, eventProperties: parameters)
    }
}

extension Logger {
    static func send(type: LogType? = nil, _ message: String, parameters: [String: Any]? = nil) {
        Task {
            var logMessage = ""
            if let type { logMessage = "[\(type.keyword)] \(message) \(type.description)" }
            else { logMessage = message }
            Logger.shared.send(logMessage, parameters: parameters)
        }
    }
}

extension Logger {
    enum LogType {
        case screen
        case tapped
        case app
        case api
        case data
        case system
        
        var keyword: String {
            switch self {
            case .screen:
                "Screen"
            case .tapped:
                "Tap Event"
            case .app:
                "App"
            case .api:
                "Network"
            case .data:
                "Data"
            case .system:
                "System"
            }
        }
        
        var description: String {
            switch self {
            case .screen:
                "화면 진입"
            case .tapped:
                "을(를) 눌렀습니다."
            case .app:
                ""
            case .api:
                ""
            case .data:
                ""
            case .system:
                ""
            }
        }
    }
}
