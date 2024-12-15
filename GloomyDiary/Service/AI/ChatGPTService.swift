//
//  ChatGPTService.swift
//  GloomyDiary
//
//  Created by 디해 on 10/13/24.
//

import Foundation
import OpenAI

final class ChatGPTService: AIServicable {
    static let shared = ChatGPTService()
    
    private let openAI: OpenAI
    
    private init() {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let token = dict["OpenAI"] as? String else { fatalError() }
        self.openAI = OpenAI(apiToken: token)
    }
    
    func generateResponse(for input: String, setting: String = "") async throws -> String {
        let query = ChatQuery(messages: [.user(.init(content: .init(string: input))),
                                         .system(.init(content: setting))], model: .gpt4_o_mini)
        let chatResult = try await openAI.chats(query: query)
        let response = chatResult.choices.map { $0.message.content?.string }.compactMap { $0 }.joined(separator: " ")
        return response
    }
}
