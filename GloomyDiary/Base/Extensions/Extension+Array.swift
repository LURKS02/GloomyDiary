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
