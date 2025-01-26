//
//  UserSetting.swift
//  GloomyDiary
//
//  Created by 디해 on 11/19/24.
//

import Foundation

struct UserSetting: Codable {
    var isFirstProcess: Bool
    var hasReviewed: Bool
    var lastReviewDeclinedDate: Date?
    var hasSuggestedNotification: Bool
}
