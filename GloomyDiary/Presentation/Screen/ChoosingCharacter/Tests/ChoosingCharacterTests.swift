//
//  ChoosingCharacterTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/16/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiary

@MainActor
struct ChoosingCharacterTests {
    @Test
    func 캐릭터_버튼을_눌러_선택_Flow() async throws {
        // 캐릭터 버튼을 눌러서 캐릭터를 선택하는 경우
        
        let store = TestStore(
            initialState: ChoosingCharacter.State(
                character: .chan
            )
        ) {
            ChoosingCharacter()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapCharacter(identifier: "gomi"))) {
            $0.character = .gomi
            $0.page = 1
        }
    }
    
    @Test
    func 페이지를_스크롤하여_선택_Flow() async throws {
        // 페이지 스크롤로 캐릭터를 선택하는 경우
        
        let store = TestStore(
            initialState: ChoosingCharacter.State(
                character: .chan
            )
        ) {
            ChoosingCharacter()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didScrollToPage(1))) {
            $0.character = .gomi
            $0.page = 1
        }
    }
    
    @Test
    func 다음_화면으로_이동_가능_Flow() async throws {
        // 다음 버튼을 누르는 경우
        
        let store = TestStore(
            initialState: ChoosingCharacter.State(
                character: .chan
            )
        ) {
            ChoosingCharacter()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapNextButton))
        await store.receive(.delegate(.navigateToCounsel(.chan)))
    }
}
