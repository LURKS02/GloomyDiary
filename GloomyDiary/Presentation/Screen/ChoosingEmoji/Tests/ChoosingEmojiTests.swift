//
//  ChoosingEmojiTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/16/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiaryExample

@MainActor
struct ChoosingEmojiTests {
    @Test
    func 기분_첫_선택_Flow() async throws {
        // emoji == nil
        // 기분을 선택한 적이 없을 때, 기분을 고르는 경우
        
        let store = TestStore(
            initialState: ChoosingEmoji.State(
                emoji: nil
            )
        ) {
            ChoosingEmoji()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapEmoji(identifier: "happy"))) {
            $0.emoji = Emoji(identifier: "happy")!
        }
    }

    @Test
    func 기분_변경_Flow() async throws {
        // emoji == "happy"
        // 기분을 선택한 적이 있을 때, 기분을 고르는 경우
        
        let store = TestStore(
            initialState: ChoosingEmoji.State(
                emoji: .happy
            )
        ) {
            ChoosingEmoji()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapEmoji(identifier: "sad"))) {
            $0.emoji = Emoji(identifier: "sad")!
        }
    }
    
    @Test
    func 다음_화면으로_이동_가능_Flow() async throws {
        // emoji != nil
        // 기분을 골랐을 때, 다음 버튼을 누르는 경우
        
        let store = TestStore(
            initialState: ChoosingEmoji.State(
                emoji: .happy
            )
        ) {
            ChoosingEmoji()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapNextButton))
        await store.receive(.delegate(.navigateToCharacterSelection))
    }
    
    @Test
    func 다음_화면으로_이동_불가능_Flow() async throws {
        // emoji == nil
        // 기분을 고르지 않았을 때, 다음 버튼을 누르는 경우
        
        let store = TestStore(
            initialState: ChoosingEmoji.State(
                emoji: nil
            )
        ) {
            ChoosingEmoji()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapNextButton))
        await store.finish()
    }
}
