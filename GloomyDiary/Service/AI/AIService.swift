//
//  AIServiceKey.swift
//  GloomyDiary
//
//  Created by 디해 on 10/22/24.
//

import Foundation
import Dependencies
import OpenAI

struct AIService {
    private let openAI: OpenAI?
    
    var generate: (_ input: String, _ setting: String) async throws -> String
    
    init(generate: @escaping (_ input: String, _ setting: String) -> String) {
        #if DEBUG
        self.openAI = nil
        
        #else
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let token = dict["OpenAI"] as? String
        else { fatalError("API Token not found") }
        
        self.openAI = OpenAI(apiToken: token)
        #endif
        
        self.generate = generate
    }
}

private enum AIServiceKey: DependencyKey {
    static var liveValue = AIService(generate: { (input, setting) -> String in
        #if DEBUG
        return "테스트 리스폰스 입니다."
        
        #else
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
