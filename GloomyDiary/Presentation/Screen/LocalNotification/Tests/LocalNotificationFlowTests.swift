//
//  LocalNotificationFlowTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/5/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiaryExample

@MainActor
struct LocalNotificationFlowTests {
    @Test func 거절_버튼을_눌러_알람_거절_Flow() async throws {
        // 알람 팝업에서 거절 버튼을 누른 경우
        
        let mock = MockUserData()
        let store = TestStore(initialState: LocalNotification.State(prepareForDismiss: false, notificationResult: nil)) {
            LocalNotification()
        } withDependencies: {
            mock.data[\.hasSuggestedNotification] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapRejectButton)) {
            $0.notificationResult = .reject
        }
        await store.send(.view(.didTapCheckButton)) {
            $0.prepareForDismiss = true
        }
        
        await store.finish()
        #expect(mock.get(keyPath: \.hasSuggestedNotification) == true)
    }
    
    @Test func 승인_버튼을_눌러_알람_승인_Flow() async throws {
        // 알람 팝업에서 승인 버튼을 누르고 알람을 설정한 경우
        
        let mock = MockUserData()
        let store = TestStore(initialState: LocalNotification.State(prepareForDismiss: false, notificationResult: nil)) {
            LocalNotification()
        } withDependencies: {
            mock.data[\.hasSuggestedNotification] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapAcceptButton)) {
            $0.notificationResult = .show
        }
        await store.send(.view(.didAcceptNotification)) {
            $0.notificationResult = .accept
        }
        await store.send(.view(.didTapCheckButton)) {
            $0.prepareForDismiss = true
        }
        
        await store.finish()
        #expect(mock.get(keyPath: \.hasSuggestedNotification) == true)
    }
    
    @Test func 승인_후_알람_거절_Flow() async throws {
        // 승인 버튼은 눌렀지만, 알람을 설정하지 않은 경우
        
        let mock = MockUserData()
        let store = TestStore(initialState: LocalNotification.State(prepareForDismiss: false, notificationResult: nil)) {
            LocalNotification()
        } withDependencies: {
            mock.data[\.hasSuggestedNotification] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapAcceptButton)) {
            $0.notificationResult = .show
        }
        await store.send(.view(.didRejectNotification)) {
            $0.notificationResult = .reject
        }
        await store.send(.view(.didTapCheckButton)) {
            $0.prepareForDismiss = true
        }
        
        await store.finish()
        #expect(mock.get(keyPath: \.hasSuggestedNotification) == true)
    }
}
