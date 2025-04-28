//
//  HomeTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/2/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiaryExample

@MainActor
struct HomeTests {
    @Test
    func 첫_화면_판별_Flow() async throws {
        // isFirstAppearance == true
        // 홈 화면을 처음 확인한 경우
        
        let store = TestStore(initialState: Home.State(isFirstAppearance: true)) {
            Home()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidAppear)) {
            $0.isFirstAppearance = false
        }
    }
    
    @Test
    func 터치하여_말풍선_변경_Flow() async throws {
        // 앱 실행 중 배경을 터치한 경우
        
        let initialTalkingType: Talking = .hello
        let store = TestStore(initialState: Home.State(
            talkingType: initialTalkingType
        )) {
            Home()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapBackground)) {
            #expect($0.talkingType != initialTalkingType)
        }
    }
    
    @Test
    func 화면_전환으로_말풍선_변경_Flow() async throws {
        // isFirstAppearance == false
        // 앱 실행 중 홈으로 돌아온 경우
        
        let initialTalkingType: Talking = .hello
        let store = TestStore(initialState: Home.State(
            talkingType: initialTalkingType,
            isFirstAppearance: false
        )) {
            Home()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidAppear))
        await store.receive(.view(.didTapBackground)) {
            #expect($0.talkingType != initialTalkingType)
        }
    }
}
