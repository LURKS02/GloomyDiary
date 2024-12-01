//
//  LocalError.swift
//  GloomyDiary
//
//  Created by 디해 on 12/2/24.
//

import Foundation

struct LocalError: Error {
    private let message: String
    
    var localizedDescription: String {
        message
    }
    
    init(message: String) {
        self.message = message
    }
}
