//
//  Review.swift
//  GloomyDiary
//
//  Created by 디해 on 11/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Review {
    @Dependency(\.userSetting) var userSetting
    @Dependency(\.date.now) var now
    
    @ObservableState
    struct State: Equatable {
    }
    
    enum Action {
        case didAcceptReview
        case didDeclineReview
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAcceptReview:
                try? userSetting.update(keyPath: \.hasReviewed, value: true)
                return .none
            case .didDeclineReview:
                try? userSetting.update(keyPath: \.lastReviewDeclinedDate, value: now)
                return .none
            }
        }
    }
}
