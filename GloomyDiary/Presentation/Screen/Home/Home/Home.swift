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
                    let sessions = try await counselingSessionRepository.fetch()
                    let hasReviewed = userSettingRepository.get(keyPath: \.hasReviewed)
                    let lastReviewDeclinedDate = userSettingRepository.get(keyPath: \.lastReviewDeclinedDate)
                    let interval: TimeInterval = 7 * 24 * 60 * 60
                    
                    if sessions.count >= 2 && !hasReviewed {
                        if isReviewSuggestionEligible(after: lastReviewDeclinedDate, within: interval) {
                            let dateString = convertDateToString(date: lastReviewDeclinedDate)
                            Logger.send(type: .system, "리뷰를 요청합니다.", parameters: ["마지막 요청 날짜": dateString])
                            await send(.showReviewSuggestion)
                        }
                    }
                    
                    let isFirstProcess = userSettingRepository.get(keyPath: \.isFirstProcess)
                    let hasSuggestedNotification = userSettingRepository.get(keyPath: \.hasSuggestedNotification)
                    if isFirstProcess == false && hasSuggestedNotification == false {
                        userSettingRepository.update(keyPath: \.hasSuggestedNotification, value: true)
                        Logger.send(type: .system, "유저에게 알림을 제안합니다.")
                        await send(.showNotificationSuggestion)
                    }
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
    func isReviewSuggestionEligible(after date: Date?, within interval: TimeInterval) -> Bool {
        guard let date = date else { return true }
        
        let currentDate = now
        let timeInterval = currentDate.timeIntervalSince(date)
        
        return timeInterval >= interval
    }
    
    func convertDateToString(date: Date?) -> String {
        guard let date else { return "없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
