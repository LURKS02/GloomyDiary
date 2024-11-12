//
//  Extension+String.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation

extension String {
    var isValidContent: Bool {
        !self.isEmpty && self.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1
    }
}
