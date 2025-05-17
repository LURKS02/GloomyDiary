//
//  UserSetting.swift
//  GloomyDiary
//
//  Created by 디해 on 11/19/24.
//

import Foundation

struct UserSetting: Codable {
    let userID: UUID
    var isFirstProcess: Bool
    var hasReviewed: Bool
    var lastReviewDeclinedDate: Date?
    var hasSuggestedNotification: Bool
    var appearanceMode: AppearanceMode
    var isLocked: Bool
    var lockHint: String
    
    init(
        userID: UUID,
        isFirstProcess: Bool,
        hasReviewed: Bool,
        lastReviewDeclinedDate: Date?,
        hasSuggestedNotification: Bool,
        appearanceMode: AppearanceMode,
        isLocked: Bool,
        lockHint: String
    ) {
        self.userID = userID
        self.isFirstProcess = isFirstProcess
        self.hasReviewed = hasReviewed
        self.lastReviewDeclinedDate = lastReviewDeclinedDate
        self.hasSuggestedNotification = hasSuggestedNotification
        self.appearanceMode = appearanceMode
        self.isLocked = isLocked
        self.lockHint = lockHint
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decodeIfPresent(UUID.self, forKey: .userID) ?? UUID()
        self.isFirstProcess = try container.decode(Bool.self, forKey: .isFirstProcess)
        self.hasReviewed = try container.decode(Bool.self, forKey: .hasReviewed)
        self.lastReviewDeclinedDate = try container.decodeIfPresent(Date.self, forKey: .lastReviewDeclinedDate)
        self.hasSuggestedNotification = try container.decode(Bool.self, forKey: .hasSuggestedNotification)
        self.appearanceMode = try container.decodeIfPresent(AppearanceMode.self, forKey: .appearanceMode) ?? .dark
        self.isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        self.lockHint = try container.decodeIfPresent(String.self, forKey: .lockHint) ?? ""
    }
}
