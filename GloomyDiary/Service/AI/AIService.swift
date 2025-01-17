//
//  AIServiceKey.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Dependencies
import Foundation
import OpenAI

struct AIService {
    static let openAI: OpenAI? = {
        #if DEBUG
        return nil
        
        #else
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let token = dict["OpenAI"] as? String
        else { fatalError("API Token not found") }

        return OpenAI(apiToken: token)
        #endif
    }()
    
    var generate: (_ input: String, _ setting: String) async throws -> String
}

private enum AIServiceKey: DependencyKey {
    static var liveValue = AIService(generate: { (input, setting) -> String in
        #if DEBUG
        return "테스트 리스폰스 입니다."
        
        #else
        guard let openAI = AIService.openAI else { throw LocalError(message: "AIService not generated") }
        
        let query = ChatQuery(messages: [
            .user(.init(content: .init(string: input))),
            .system(.init(content: setting))
        ], model: .gpt4_o_mini)
        let chatResult = try await openAI.chats(query: query)
        let response = chatResult.choices
            .map { $0.message.content?.string }
            .compactMap { $0 }
            .joined(separator: " ")
        return response
        #endif
        })
    
    static var testValue = AIService(generate: { (input, setting) -> String in
        return "테스트 리스폰스 입니다."
    })
}

extension DependencyValues {
    var aiService: AIService {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}
