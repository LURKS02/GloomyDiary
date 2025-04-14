//
//  HistoryMenuTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 4/13/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiaryExample

@MainActor
struct HistoryMenuTests {
    @Test
    func 메뉴_삭제_아이템_클릭_Flow() async throws {
        // 메뉴 아이템에서 삭제를 선택한 경우
        
        let store = TestStore(
            initialState: HistoryMenu.State()
        ) {
            HistoryMenu()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapMenuButton(.delete))) {
            $0.prepareForDismiss = true
            $0.flag = .delete
        }
    }
    
    @Test
    func 메뉴_공유_아이템_클릭_Flow() async throws {
        // 메뉴 아이템에서 공유를 선택한 경우
        
        let store = TestStore(
            initialState: HistoryMenu.State()
        ) {
            HistoryMenu()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapMenuButton(.share))) {
            $0.prepareForDismiss = true
            $0.flag = .sharing
        }
    }

    @Test
    func 배경을_눌러_메뉴_닫기_Flow() async throws {
        // 배경을 눌러 메뉴를 닫는 경우
        
        let store = TestStore(
            initialState: HistoryMenu.State()
        ) {
            HistoryMenu()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapBackground)) {
            $0.prepareForDismiss = true
        }
    }
    
    @Test
    func normal_dismiss_준비가_완료된_Flow() async throws {
        // normal 상태에서 뷰에서 dismiss 요청을 보내는 경우
        
        var didCallDismiss = false
        let store = TestStore(
            initialState: HistoryMenu.State()
        ) {
            HistoryMenu()
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
    func sharing_dismiss_준비가_완료된_Flow() async throws {
        // sharing 상태에서 뷰에서 dismiss 요청을 보내는 경우
        
        var didCallDismiss = false
        let store = TestStore(
            initialState: HistoryMenu.State(
                flag: .sharing
            )
        ) {
            HistoryMenu()
        } withDependencies: {
            $0.dismiss = .init({
                didCallDismiss = true
            })
        }
        
        // MARK: - Flow Start
        await store.send(.view(.dismiss(.sharing)))
        await store.receive(.delegate(.didTapShare))
        
        #expect(didCallDismiss == true)
    }
    
    @Test
    func delete_dismiss_준비가_완료된_Flow() async throws {
        // delete 상태에서 뷰에서 dismiss 요청을 보내는 경우
        
        var didCallDismiss = false
        let store = TestStore(
            initialState: HistoryMenu.State(
                flag: .delete
            )
        ) {
            HistoryMenu()
        } withDependencies: {
            $0.dismiss = .init({
                didCallDismiss = true
            })
        }
        
        // MARK: - Flow Start
        await store.send(.view(.dismiss(.delete)))
        await store.receive(.delegate(.didTapDelete))
        
        #expect(didCallDismiss == true)
    }
}
