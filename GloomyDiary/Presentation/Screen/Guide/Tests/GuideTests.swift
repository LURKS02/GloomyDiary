//
//  GuideTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 3/27/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiaryExample

@MainActor
struct GuideTests {
    @Test
    func 애니메이션_실행_Flow() async throws {
        // 화면을 눌러 애니메이션을 실행하는 경우 (애니메이션 Limit에 도달하기 전)
        
        let store = TestStore(
            initialState: Guide.State(
                animationCount: 0,
                animationLimit: 4
            )
        ) {
            Guide()
        }
        
        // MARK: - Flow Start
        
        await store.send(.view(.didTapBackground)) {
            $0.animationCount = 1
            $0.animationLimit = 4
        }
    }
    
    @Test
    func 애니메이션_종료_후_다음_화면으로_이동_Flow() async throws {
        // 화면을 눌러 애니메이션을 실행하는 경우 (애니메이션 Limit에 도달)
        
        let store = TestStore(
            initialState: Guide.State(
                animationCount: 3,
                animationLimit: 4
            )
        ) {
            Guide()
        }
        
        // MARK: - Flow Start
        
        await store.send(.view(.didTapBackground)) {
            $0.animationCount = 4
            $0.animationLimit = 4
        }
        
        await store.receive(.inner(.animationDidEnd))
        await store.receive(.delegate(.navigateToStartCounsel))
    }
}
