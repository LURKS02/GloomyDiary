//
//  HistoryDeleteTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 4/13/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import GloomyDiary

@MainActor
struct HistoryDeleteTests {
    @Test
    func 배경을_눌러_삭제_취소_Flow() async throws {
        // 배경을 눌러 삭제 동작을 취소하는 경우
        
        let store = TestStore(
            initialState: HistoryDelete.State(
                sessionID: UUID(0),
                counselor: .chan,
                flag: .normal
            )
        ) {
            HistoryDelete()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapBackground))
        await store.receive(.inner(.prepareForDismiss)) {
            $0.prepareForDismiss = true
        }
    }

    @Test func 거절_버튼을_눌러_삭제_취소_Flow() async throws {
        // 거절 버튼을 눌러 삭제 동작을 취소하는 경우
        
        let store = TestStore(
            initialState: HistoryDelete.State(
                sessionID: UUID(0),
                counselor: .chan,
                flag: .normal
            )
        ) {
            HistoryDelete()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapRejectButton))
        await store.receive(.inner(.prepareForDismiss)) {
            $0.prepareForDismiss = true
        }
    }
    
    @Test
    func 수락_버튼을_눌러_삭제_Flow() async throws {
        // 수락 버튼을 눌러 일기를 삭제하는 경우
        
        let store = TestStore(
            initialState: HistoryDelete.State(
                sessionID: UUID(0),
                counselor: .chan,
                flag: .normal
            )
        ) {
            HistoryDelete()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapAcceptButton)) {
            $0.flag = .delete
        }
        await store.receive(.inner(.prepareForDismiss)) {
            $0.prepareForDismiss = true
        }
    }
    
    @Test
    func normal_dismiss_준비가_완료된_Flow() async throws {
        // normal 상태에서 뷰에서 dismiss 요청을 보내는 경우
        
        var didCallDismiss = false
        let store = TestStore(
            initialState: HistoryDelete.State(
                sessionID: UUID(0),
                counselor: .chan,
                flag: .normal
            )
        ) {
            HistoryDelete()
        } withDependencies: {
            $0.dismiss = .init({
                didCallDismiss = true
            })
        }
        
        // MARK: - Flow Start
        await store.send(.view(.dismiss(.normal)))
        
        #expect(didCallDismiss == true)
    }
    
    @Test
    func delete_dismiss_준비가_완료된_Flow() async throws {
        // delete 상태에서 뷰에서 dismiss 요청을 보내는 경우
        
        var didCallDismiss = false
        let store = TestStore(
            initialState: HistoryDelete.State(
                sessionID: UUID(0),
                counselor: .chan,
                flag: .delete
            )
        ) {
            HistoryDelete()
        } withDependencies: {
            $0.dismiss = .init({
                didCallDismiss = true
            })
        }
        
        // MARK: - Flow Start
        await store.send(.view(.dismiss(.delete)))
        await store.receive(.delegate(.deleteHistory))
        
        #expect(didCallDismiss == true)
    }
}
