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
    var appearanceMode: AppearanceMode
    
    init(
        isFirstProcess: Bool,
        hasReviewed: Bool,
        lastReviewDeclinedDate: Date?,
        hasSuggestedNotification: Bool,
        appearanceMode: AppearanceMode
    ) {
        self.isFirstProcess = isFirstProcess
        self.hasReviewed = hasReviewed
        self.lastReviewDeclinedDate = lastReviewDeclinedDate
        self.hasSuggestedNotification = hasSuggestedNotification
        self.appearanceMode = appearanceMode
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isFirstProcess = try container.decode(Bool.self, forKey: .isFirstProcess)
        self.hasReviewed = try container.decode(Bool.self, forKey: .hasReviewed)
        self.lastReviewDeclinedDate = try container.decode(Date.self, forKey: .lastReviewDeclinedDate)
        self.hasSuggestedNotification = try container.decode(Bool.self, forKey: .hasSuggestedNotification)
        self.appearanceMode = try container.decodeIfPresent(AppearanceMode.self, forKey: .appearanceMode) ?? .default
    }
}

enum AppearanceMode: Codable {
    case `default`
    case light
    case dark
}
