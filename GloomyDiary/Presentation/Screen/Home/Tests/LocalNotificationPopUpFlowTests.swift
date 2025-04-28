//
//  LocalNotificationFlowTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/5/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiaryExample

struct LocalNotificationPopUpFlowTests {
    @Test
    func 과거에_알람_요청_Flow() async throws {
        // isFirstAppearance == false
        // hasSuggestedNotification == true
        // 앱 실행 중 홈으로 돌아왔고, 알람 요청을 한 적이 있는 경우
        
        let store = TestStore(initialState: Home.State(isFirstAppearance: false)) {
            Home()
        } withDependencies: {
            let mock = MockUserData()
            mock.data[\.hasSuggestedNotification] = true
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidAppear))
        await store.receive(.inner(.checkReviewRequestStatus))
    }
    
    @Test
    func 알람_요청_Flow() async throws {
        // isFirstAppearance == false
        // hasSuggestedNotification == false
        // 앱 실행 중 홈으로 돌아왔고, 알람 요청을 한 적이 없는 경우
        
        let store = TestStore(initialState: Home.State(isFirstAppearance: false)) {
            Home()
        } withDependencies: {
            let mock = MockUserData()
            mock.data[\.hasSuggestedNotification] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidAppear)) {
            $0.destination = nil
        }
        await store.receive(.inner(.checkNotiRequestStatus))
        await store.receive(.inner(.requestNoti)) {
            $0.destination = .notification(.init())
        }
    }
}
