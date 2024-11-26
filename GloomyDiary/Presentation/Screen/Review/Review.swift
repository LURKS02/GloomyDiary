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
    @Dependency(\.userSettingRepository) var userSettingRepository
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
                userSettingRepository.update(keyPath: \.hasReviewed, value: true)
                return .none
            case .didDeclineReview:
                userSettingRepository.update(keyPath: \.lastReviewDeclinedDate, value: now)
                return .none
            }
        }
    }
}
