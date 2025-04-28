//
//  HistoryTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 4/13/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import GloomyDiaryExample

@MainActor
struct HistoryTests {
    @Test
    func 리프레쉬_Flow() async throws {
        // 다른 화면에서 돌아와 리프레쉬 되는 경우
        
        let testSessionRepository = MockCounselingSessionRepository()
        let store = TestStore(
            initialState: History.State(
                page: 10,
                isLoading: false,
                isEndOfPage: true
            )
        ) {
            History()
        } withDependencies: {
            $0.counselingSessionRepository = testSessionRepository
            $0.uuid = .incrementing
        }
        
        // MARK: - Flow Start
        await store.send(.view(.refresh)) {
            $0.page = 0
            $0.isLoading = true
            $0.isEndOfPage = false
        }
        
        await store.receive(.inner(.initializeSession(testSessionRepository.sessions))) {
            $0.items = [SessionItem(uuid: UUID(0), session: testSessionRepository.sessions[0])]
        }
    }
    
    @Test
    func 다음_페이지_불러오기_Flow() async throws {
        // 스크롤의 끝에 도달하여 다음 페이지를 불러오는 경우
        
        let testSessionRepository = MockCounselingSessionRepository()
        let store = TestStore(
            initialState: History.State(
                page: 0,
                isLoading: false,
                isEndOfPage: false
            )
        ) {
            History()
        } withDependencies: {
            $0.counselingSessionRepository = testSessionRepository
            $0.uuid = .incrementing
        }
        
        // MARK: - Flow Start
        await store.send(.view(.loadNextPage)) {
            $0.page = 1
            $0.isLoading = true
        }
        await store.receive(.inner(.sessionResponse(testSessionRepository.sessions))) {
            $0.isLoading = false
            $0.items = [SessionItem(uuid: UUID(0), session: testSessionRepository.sessions[0])]
        }
    }
    
    @Test
    func 페이지의_끝에_도달_Flow() async throws {
        // 페이지의 끝에 도달하여 다음 페이지를 불러올 수 없는 경우
        
        let testSessionRepository = MockCounselingSessionRepository(sessions: [])
        
        let store = TestStore(
            initialState: History.State(
                page: 0,
                isLoading: false,
                isEndOfPage: false
            )
        ) {
            History()
        } withDependencies: {
            $0.counselingSessionRepository = testSessionRepository
        }
        
        // MARK: - Flow Start
        await store.send(.view(.loadNextPage)) {
            $0.page = 1
            $0.isLoading = true
        }
        await store.receive(.inner(.stopFetchingPages)) {
            $0.isEndOfPage = true
        }
    }
    
    @Test
    func 기록_삭제_Flow() async throws {
        // 기록이 삭제된 경우
        
        let session = Session(
            id: UUID(0),
            counselor: .chan,
            title: "test title",
            query: "test query",
            response: "test response",
            createdAt: Date(timeIntervalSinceReferenceDate: 1234567890),
            weather: .sunny,
            emoji: .happy,
            imageIDs: []
        )
        
        let store = TestStore(
            initialState: History.State(
                items: [SessionItem(
                    uuid: UUID(0),
                    session: session
                )]
            )
        ) {
            History()
        }
        
        // MARK: - Flow Start
        await store.send(.scope(.didRemoveSession(UUID(0)))) {
            $0.items = []
        }
    }
    
    @Test
    func 상세_이동_Flow() async throws {
        // 상세 기록으로 이동하는 경우
        
        let store = TestStore(
            initialState: History.State(
                isNavigating: true
            )
        ) {
            History()
        }
        
        // MARK: - Flow Start
        await store.send(.scope(.didNavigateToDetail)) {
            $0.isNavigating = false
        }
    }
}
