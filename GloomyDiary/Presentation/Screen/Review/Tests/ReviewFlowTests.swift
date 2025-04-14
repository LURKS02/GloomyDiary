//
//  ReviewFlowTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/5/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import GloomyDiaryExample

@MainActor
struct ReviewFlowTests {
    @Test func 배경_화면을_눌러_리뷰_거절_Flow() async throws {
        // 리뷰 팝업에서 배경을 터치한 경우
        
        let mock = MockUserData()
        let store = TestStore(initialState: Review.State(prepareForDismiss: false)) {
            Review()
        } withDependencies: {
            let date = Date(timeIntervalSinceReferenceDate: 1234567890)
            $0.date.now = date
            mock.data[\.hasReviewed] = false
            mock.data[\.lastReviewDeclinedDate] = nil
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapBackground))
        await store.receive(.inner(.didRejectReview))
        await store.receive(.inner(.prepareForDismiss)) {
            $0.prepareForDismiss = true
        }
        
        await store.finish()
        #expect(mock.get(keyPath: \.lastReviewDeclinedDate) == Date(timeIntervalSinceReferenceDate: 1234567890))
        #expect(mock.get(keyPath: \.hasReviewed) == false)
    }

    @Test func 거절_버튼을_눌러_리뷰_거절_Flow() async throws {
        // 리뷰 팝업에서 거절 버튼을 누른 경우
        
        let mock = MockUserData()
        let store = TestStore(initialState: Review.State(prepareForDismiss: false)) {
            Review()
        } withDependencies: {
            let date = Date(timeIntervalSinceReferenceDate: 1234567890)
            $0.date.now = date
            mock.data[\.hasReviewed] = false
            mock.data[\.lastReviewDeclinedDate] = nil
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapRejectButton))
        await store.receive(.inner(.didRejectReview))
        await store.receive(.inner(.prepareForDismiss)) {
            $0.prepareForDismiss = true
        }
        
        await store.finish()
        #expect(mock.get(keyPath: \.lastReviewDeclinedDate) == Date(timeIntervalSinceReferenceDate: 1234567890))
        #expect(mock.get(keyPath: \.hasReviewed) == false)
    }
    
    @Test func 리뷰_작성_Flow() async throws {
        // 리뷰 팝업에서 승인 버튼을 누르고, 리뷰 팝업을 연 경우
        
        let mock = MockUserData()
        let store = TestStore(initialState: Review.State(prepareForDismiss: false)) {
            Review()
        } withDependencies: {
            mock.data[\.hasReviewed] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapAcceptButton))
        await store.receive(.delegate(.didRequestReview))
        await store.receive(.inner(.prepareForDismiss)) {
            $0.prepareForDismiss = true
        }
        
        await store.finish()
        #expect(mock.get(keyPath: \.hasReviewed) == true)
    }
}
