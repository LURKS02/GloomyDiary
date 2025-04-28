//
//  HistoryDetailTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 4/13/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import GloomyDiaryExample

@MainActor
struct HistoryDetailTests {
    @Test
    func 화면_이동을_완료하는_Flow() async throws {
        // 상세 화면으로 이동을 완료하여 신호를 보내는 경우
        
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        let store = TestStore(initialState: HistoryDetail.State(session: session)
        ) {
            HistoryDetail()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidLoad))
        await store.receive(.delegate(.didNavigateToDetail))
    }

    @Test
    func 메뉴_버튼을_누르는_Flow() async throws {
        // 메뉴 버튼을 눌러 메뉴 아이템을 여는 경우
        
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        let store = TestStore(
            initialState: HistoryDetail.State(
                destination: nil,
                session: session
            )
        ) {
            HistoryDetail()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapMenuButton)) {
            $0.destination = .menu(.init())
        }
    }
    
    @Test
    func 뒤로가기_버튼을_누르는_Flow() async throws {
        // 뒤로가기 버튼을 눌러 상세 화면을 닫는 경우
        
        var didCallDismiss = false
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        let store = TestStore(
            initialState: HistoryDetail.State(
                destination: nil,
                session: session
            )
        ) {
            HistoryDetail()
        } withDependencies: {
            $0.dismiss = .init({
                didCallDismiss = true
            })
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapBackButton))
        
        #expect(didCallDismiss == true)
    }
    
    @Test
    func 메뉴에서_삭제를_누른_Flow() async throws {
        // 메뉴에서 삭제 아이템을 누른 경우
        
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        let store = TestStore(
            initialState: HistoryDetail.State(
                destination: .menu(.init()),
                session: session
            )
        ) {
            HistoryDetail()
        }
        
        // MARK: - Flow Start
        await store.send(.scope(.destination(.presented(.menu(.delegate(.didTapDelete)))))) {
            $0.destination = .delete(
                .init(
                    sessionID: UUID(0),
                    counselor: .chan
                )
            )
        }
    }
    
    @Test
    func 메뉴에서_공유를_누른_Flow() async throws {
        // 메뉴에서 공유 아이템을 누른 경우
        
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        let store = TestStore(
            initialState: HistoryDetail.State(
                destination: .menu(.init()),
                session: session
            )
        ) {
            HistoryDetail()
        }
        
        // MARK: - Flow Start
        await store.send(.scope(.destination(.presented(.menu(.delegate(.didTapShare)))))) {
            $0.destination = .activity
        }
    }
    
    @Test
    func 삭제_화면에서_삭제를_누른_Flow() async throws {
        // 삭제 화면에서 삭제하기를 선택하여 일기를 삭제하는 경우
        
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        var didCallDismiss = false
        let store = TestStore(
            initialState: HistoryDetail.State(
                destination: .delete(
                    .init(
                        sessionID: UUID(0),
                        counselor: .chan
                    )
                ),
                session: session
            )
        ) {
            HistoryDetail()
        } withDependencies: {
            $0.dismiss = .init({
                didCallDismiss = true
            })
        }
        
        // MARK: - Flow Start
        await store.send(.scope(.destination(.presented(.delete(.delegate(.deleteHistory))))))
        await store.receive(.delegate(.deleteSession(UUID(0))))
        
        #expect(didCallDismiss == true)
    }
    
    @Test
    func 보여주는_화면에서_dismiss_되는_Flow() async throws {
        // 보여주는 화면에서 dismiss가 호출된 경우
        
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "",
            query: "",
            response: "",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        let store = TestStore(
            initialState: HistoryDetail.State(
                destination: .menu(.init()),
                session: session
            )
        ) {
            HistoryDetail()
        }
        
        // MARK: - Flow Start
        await store.send(.scope(.destination(.dismiss))) {
            $0.destination = nil
        }
    }
}
