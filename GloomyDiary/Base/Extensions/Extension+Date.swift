//
//  Extension+Date.swift
//  GloomyDiary
//
//  Created by 디해 on 10/17/24.
//

import Foundation

extension Date {
    var normalDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}
