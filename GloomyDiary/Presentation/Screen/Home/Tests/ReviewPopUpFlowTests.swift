//
//  ReviewFlowTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/5/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import GloomyDiary

@MainActor
struct ReviewPopUpFlowTests {
    @Test
    func 리뷰_요청_후_승인_Flow() async throws {
        // isFirstAppearance == false
        // hasSuggestedNotification == true
        // now - lastReviewDeclinedDate == 604800
        // hasReviewed == false
        // 앱 실행 중 홈으로 돌아왔고, 알람 요청을 한 적이 있고,
        // 아직 리뷰를 작성하지 않았으며, 마지막 요청 날짜로부터 7일 이상 지난 상태에서
        // 리뷰 작성 버튼을 누른 경우
        
        let store = TestStore(
            initialState: Home.State(
                isReviewSuggested: false,
                isFirstAppearance: false)
        ) {
            Home()
        } withDependencies: {
            let referenceDate = Date(timeIntervalSinceReferenceDate: 1234567890)
            let oneWeekAgo = referenceDate.addingTimeInterval(-7 * 24 * 60 * 60)
            $0.date.now = referenceDate
            
            let mock = MockUserData()
            mock.data[\.hasSuggestedNotification] = true
            mock.data[\.lastReviewDeclinedDate] = oneWeekAgo
            mock.data[\.hasReviewed] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidAppear)) {
            $0.destination = nil
        }
        await store.receive(.inner(.checkNotiRequestStatus))
        await store.receive(.inner(.checkReviewRequestStatus))
        await store.receive(.inner(.checkIfReviewRequestable(Date(timeIntervalSinceReferenceDate: 1234567890).addingTimeInterval(-7 * 24 * 60 * 60))))
        await store.receive(.inner(.requestReview)) {
            $0.destination = .review(.init())
        }
        
        await store.send(.scope(.destination(.presented(.review(.delegate(.didRequestReview)))))) {
            $0.isReviewSuggested = true
        }
    }
    
    @Test
    func 리뷰_요청_시간_제한_Flow() async throws {
        // isFirstAppearance == false
        // hasSuggestedNotification == true
        // hasReviewed == true
        // 앱 실행 중 홈으로 돌아왔고, 알람 요청을 한 적이 있고,
        // 아직 리뷰를 작성한 적이 없고, 마지막 요청 날짜로부터 7일 이상 지나지 않은 경우
        
        let store = TestStore(initialState: Home.State(isFirstAppearance: false)) {
            Home()
        } withDependencies: {
            let referenceDate = Date(timeIntervalSinceReferenceDate: 1234567890)
            let oneWeekAgo = referenceDate.addingTimeInterval(-604800)
            $0.date.now = referenceDate
            
            let mock = MockUserData()
            mock.data[\.hasSuggestedNotification] = true
            mock.data[\.lastReviewDeclinedDate] = oneWeekAgo
            mock.data[\.hasReviewed] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidAppear)) {
            $0.destination = nil
        }
        await store.receive(.inner(.checkNotiRequestStatus))
        await store.receive(.inner(.checkReviewRequestStatus)) {
            $0.destination = nil
        }
        await store.finish()
    }
    
    @Test
    func 리뷰_요청_재요청_기간이_아닌_경우_Flow() async throws {
        // isFirstAppearance == false
        // hasSuggestedNotification == true
        // now - lastReviewDeclinedDate < 604800
        // hasReviewed == false
        // 앱 실행 중 홈으로 돌아왔고, 알람 요청을 한 적이 있고,
        // 아직 리뷰를 작성하지 않았으며, 마지막 요청 날짜로부터 7일 이상 지나지 않은 경우
        
        let store = TestStore(initialState: Home.State(isFirstAppearance: false)) {
            Home()
        } withDependencies: {
            let referenceDate = Date(timeIntervalSinceReferenceDate: 1234567890)
            let oneWeekAgo = referenceDate.addingTimeInterval(-604799)
            $0.date.now = referenceDate
            
            let mock = MockUserData()
            mock.data[\.hasSuggestedNotification] = true
            mock.data[\.lastReviewDeclinedDate] = oneWeekAgo
            mock.data[\.hasReviewed] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidAppear)) {
            $0.destination = nil
        }
        await store.receive(.inner(.checkNotiRequestStatus))
        await store.receive(.inner(.checkReviewRequestStatus))
        await store.receive(.inner(.checkIfReviewRequestable(Date(timeIntervalSinceReferenceDate: 1234567890).addingTimeInterval(-604799)))) {
            $0.destination = nil
        }
        
        await store.finish()
    }
}
