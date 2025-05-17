//
//  ThemeScheduling.swift
//  GloomyDiary
//
//  Created by 디해 on 4/24/25.
//

import Foundation

protocol ThemeScheduling {
    var resolvedDefault: AppearanceMode { get }
    
    func start()
}
