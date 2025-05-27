//
//  Extension+Array.swift
//  GloomyDiary
//
//  Created by 디해 on 1/19/25.
//

import Foundation

extension Array where Element: Equatable {
    func exclude(_ elements: Element...) -> [Element] {
        return self.filter { !elements.contains($0) }
    }
}

extension Array where Element == String {
    static func fromJSONString(_ jsonString: String?) -> [String] {
        guard let jsonString,
              let data = jsonString.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return array
    }
    
    func toJSONString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
