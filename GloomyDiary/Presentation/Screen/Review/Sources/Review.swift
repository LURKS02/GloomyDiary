//
//  Review.swift
//  GloomyDiary
//
//  Created by 디해 on 11/27/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Review {
    @Dependency(\.date.now) var now
    @Dependency(\.logger) var logger
    @Dependency(\.userSetting) var userSetting
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable {
        var prepareForDismiss: Bool = false
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapBackground
        case didTapRejectButton
        case didTapAcceptButton
        case dismiss
    }
    enum InnerAction: Equatable {
        case didRejectReview
        case prepareForDismiss
    }
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case didRequestReview
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapBackground:
                    return .run { send in
                        await send(.inner(.didRejectReview))
                    }
                    
                case .didTapRejectButton:
                    return .run { send in
                        await send(.inner(.didRejectReview))
                    }
                    
                case .didTapAcceptButton:
                    return .run { send in
                        logger.send(.tapped, "승인 버튼을 눌러 리뷰 작성 창이 보여집니다.", nil)
                        try? userSetting.update(keyPath: \.hasReviewed, value: true)
                        await send(.delegate(.didRequestReview))
                        await send(.inner(.prepareForDismiss))
                    }
                    
                case .dismiss:
                    return .run { _ in
                        await dismiss()
                    }
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .didRejectReview:
                    return .run { send in
                        logger.send(.tapped, "리뷰를 거절하였습니다.", nil)
                        try? userSetting.update(keyPath: \.lastReviewDeclinedDate, value: now)
                        await send(.inner(.prepareForDismiss))
                    }
                    
                case .prepareForDismiss:
                    state.prepareForDismiss = true
                    return .none
                }
                
            case .delegate(let delegateAction):
                switch delegateAction {
                case .didRequestReview:
                    return .none
                }
            }
        }
    }
}
