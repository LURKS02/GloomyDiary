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
    private let amplitude: Amplitude?
    
    var send: (
        _ type: LogType?,
        _ message: String,
        _ parameters: [String: Any]?
    ) -> Void
    
    init(send: @escaping (LogType?, String, [String : Any]?) -> Void) {
        #if DEBUG
        self.amplitude = nil
        
        #else
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = dict["AmplitudeAPIKey"] as? String
        else { fatalError("Amplitude Key not found") }
        
        self.amplitude = Amplitude(
            configuration: Configuration(
                apiKey: key,
                autocapture: []
            )
        )
        #endif
        
        self.send = send
    }
}

private enum LoggerKey: DependencyKey {
    static var liveValue = Logger(send: { (type, message, parameters) -> Void in
        #if DEBUG
        return
        
        #else
        var message = ""
        if let type {
            message = "[\(type.keyword)] \(message) \(type.description)" }
        else { message = message }
        amplitude?.track(eventType: message, eventProperties: parameters)
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
