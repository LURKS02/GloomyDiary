//
//  Home.swift
//  GloomyDiary
//
//  Created by 디해 on 8/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Home {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    @Dependency(\.userSettingRepository) var userSettingRepository
    @Dependency(\.date.now) var now
    
    @ObservableState
    struct State: Equatable {
        var talkingType: Talking = .hello
        var showReviewSuggestion: Bool = false
        var showNotificationSuggestion: Bool = false
    }
    
    enum Action {
        case viewDidAppear
        case showNotificationSuggestion
        case showReviewSuggestion
        case hideSuggestions
        case ghostTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return .run { send in
                    if isNotificationSuggestable() {
                        await suggestNotification(send: send)
                    } else {
                        let lastReviewDeclinedDate = userSettingRepository.get(keyPath: \.lastReviewDeclinedDate)
                        if try await isReviewSuggestionEligible(date: lastReviewDeclinedDate) {
                            await suggestReview(send: send, lastReviewDeclinedDate: lastReviewDeclinedDate)
                        }
                    }
                    await send(.ghostTapped)
                }
                
            case .ghostTapped:
                state.talkingType = Talking.getRandomElement(with: state.talkingType)
                return .none
                
            case .showReviewSuggestion:
                state.showReviewSuggestion = true
                return .none
                
            case .showNotificationSuggestion:
                state.showNotificationSuggestion = true
                return .none
                
            case .hideSuggestions:
                state.showReviewSuggestion = false
                state.showNotificationSuggestion = false
                return .none
            }
        }
    }
}

private extension Home {
    func suggestNotification(send: Send<Action>) async {
        userSettingRepository.update(keyPath: \.hasSuggestedNotification, value: true)
        Logger.send(type: .system, "유저에게 알림을 제안합니다.")
        await send(.showNotificationSuggestion)
    }

    func suggestReview(send: Send<Action>, lastReviewDeclinedDate: Date?) async {
        let dateString = convertDateToString(date: lastReviewDeclinedDate)
        Logger.send(type: .system, "리뷰를 요청합니다.", parameters: ["마지막 요청 날짜": dateString])
        await send(.showReviewSuggestion)
    }
    
    func isNotificationSuggestable() -> Bool {
        let hasSuggestedNotification = userSettingRepository.get(keyPath: \.hasSuggestedNotification)
        return !hasSuggestedNotification
    }
    
    func isReviewSuggestionEligible(date: Date?) async throws -> Bool {
        let sessions = try await counselingSessionRepository.fetch()
        if date == nil && sessions.count < 2 { return false }
        else {
            let hasReviewed = userSettingRepository.get(keyPath: \.hasReviewed)
            if hasReviewed { return false }
            
            if let date = date {
                let interval: TimeInterval = 7 * 24 * 60 * 60
                let currentDate = now
                let timeInterval = currentDate.timeIntervalSince(date)
                return timeInterval >= interval
            } else {
                return true
            }
        }
    }
    
    func convertDateToString(date: Date?) -> String {
        guard let date else { return "없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
