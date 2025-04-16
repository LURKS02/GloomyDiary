//
//  Home.swift
//  GloomyDiary
//
//  Created by 디해 on 8/14/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Home {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    @Dependency(\.userSetting) var userSetting
    @Dependency(\.logger) var logger
    @Dependency(\.date.now) var now
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        
        var talkingType: Talking = .hello
        var showNotificationSuggestion: Bool = false
        var isReviewSuggested: Bool = false
        var isFirstAppearance: Bool = true
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case viewDidAppear
        case didTapBackground
        case didTapStartButton
    }
    
    enum InnerAction: Equatable {
        case checkNotiRequestStatus
        case checkReviewRequestStatus
        case checkIfReviewRequestable(Date?)
        case requestReview
        case requestNoti
    }
    
    @CasePathable
    enum ScopeAction: Equatable {
        case destination(PresentationAction<Destination.Action>)
    }
    
    enum DelegateAction: Equatable {}
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .viewDidAppear:
                    if state.isFirstAppearance {
                        state.isFirstAppearance = false
                        return .none
                    } else {
                        return .merge(
                            .run { send in
                                await send(.inner(.checkNotiRequestStatus))
                            },
                            .run { send in
                                await send(.view(.didTapBackground))
                            }
                        )
                    }
                    
                case .didTapBackground:
                    state.talkingType = Talking.getRandomElement(with: state.talkingType)
                    logger.send(.tapped, "홈: 배경을 눌러 말풍선을 바꿉니다.", nil)
                    return .none
                    
                case .didTapStartButton:
                    state.destination = .counseling(.init())
                    logger.send(.tapped, "홈: 편지 쓰기 버튼을 눌러 상담을 시작합니다.", nil)
                    return .none
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .checkNotiRequestStatus:
                    return .run { send in
                        let hasRequestedNoti = userSetting.get(keyPath: \.hasSuggestedNotification)
                        
                        if hasRequestedNoti {
                            await send(.inner(.checkReviewRequestStatus))
                        } else {
                            await send(.inner(.requestNoti))
                        }
                    }
                    
                case .checkReviewRequestStatus:
                    return .run { send in
                        let lastDate = userSetting.get(keyPath: \.lastReviewDeclinedDate)
                        let hasReviewed = userSetting.get(keyPath: \.hasReviewed)
                        
                        if !hasReviewed {
                            await send(.inner(.checkIfReviewRequestable(lastDate)))
                        }
                    }
                    
                case .checkIfReviewRequestable(let lastDate):
                    return .run { send in
                        guard let lastDate else { return await send(.inner(.requestReview)) }
                        
                        let interval: TimeInterval = 7 * 24 * 60 * 60
                        let currentDate = now
                        let timeInterval = currentDate.timeIntervalSince(lastDate)
                        
                        if timeInterval >= interval { await send(.inner(.requestReview)) }
                        else { return }
                    }
                    
                case .requestReview:
                    state.destination = .review(.init())
                    logger.send(.system, "리뷰를 제안했습니다.", nil)
                    return .none
                    
                case .requestNoti:
                    state.destination = .notification(.init())
                    logger.send(.system, "알림을 제안했습니다.", nil)
                    return .none
                }
                
            case .scope(.destination(.presented(.review(.delegate(.didRequestReview))))):
//                state.isReviewSuggested = true
                return .none
                
            case .scope(.destination(.dismiss)):
                state.destination = nil
                return .none
                
            case .scope:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.scope.destination)
    }
}

extension Home {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case review(Review)
        case notification(LocalNotification)
        case counseling(CounselNavigation)
    }
}
