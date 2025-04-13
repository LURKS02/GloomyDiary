//
//  CounselResultTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 4/13/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import GloomyDiary

@MainActor
struct CounselResultTests {
    @Test
    func 세션_업데이트_Flow() async throws {
        // 세션 데이터를 받아서 적용하는 경우
        
        let store = TestStore(
            initialState: CounselResult.State(
                counselor: .chan
            )
        ) {
            CounselResult()
        }
        
        // MARK: - Flow Start
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
        
        await store.send(.view(.updateResponse(session))) {
            $0.session = session
        }
    }

    @Test
    func 홈_버튼_클릭_Flow() async throws {
        // 홈 버튼을 눌러 결과를 닫는 경우
        
        let store = TestStore(
            initialState: CounselResult.State(
                counselor: .chan
            )
        ) {
            CounselResult()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapHomeButton))
        await store.receive(.delegate(.dismiss))
    }
    
    @Test
    func 공유_버튼_클릭_Flow() async throws {
        // 공유 버튼을 눌러 공유 화면을 여는 경우
        
        let store = TestStore(
            initialState: CounselResult.State(
                counselor: .chan
            )
        ) {
            CounselResult()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapShareButton)) {
            $0.destination = .activity
        }
    }
    
    @Test
    func 뒤로가기_버튼_클릭_Flow() async throws {
        // 네트워크 에러 발생 시 뒤로가기 버튼을 눌러 이전 화면으로 이동하는 경우
        
        var didCallDismiss = false
        let store = TestStore(
            initialState: CounselResult.State(
                counselor: .chan
            )
        ) {
            CounselResult()
        } withDependencies: {
            $0.dismiss = .init({
                didCallDismiss = true
            })
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapBackButton))
        
        #expect(didCallDismiss == true)
    }
}
