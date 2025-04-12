//
//  WelcomeTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 3/27/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiary

@MainActor
struct WelcomeTests {
    @Test
    func 유령을_눌러_다음_화면으로_이동_Flow() async throws {
        // 유령을 누르는 경우
        
        let store = TestStore(
            initialState: Welcome.State()
        ) {
            Welcome()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapGhost))
        await store.receive(.delegate(.navigateToGuide))
    }
}
