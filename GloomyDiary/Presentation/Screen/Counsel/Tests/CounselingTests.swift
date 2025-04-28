//
//  CounselingTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 3/27/25.
//

import ComposableArchitecture
import Testing
import UIKit

@testable import GloomyDiaryExample

@MainActor
struct CounselingTests {
    @Test
    func Picker_선택_가능_Flow() async throws {
        // 사진을 선택 가능한 경우
        
        let store = TestStore(
            initialState: Counseling.State(
                maxSelectionLimit: 10,
                title: "",
                weather: .sunny,
                emoji: .happy,
                character: .chan,
                selections: []
            )) {
                Counseling()
            }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapPicker)) {
            $0.picker = Picker.State(selectionLimit: 10)
        }
    }
    
    @Test
    func Picker_선택_불가능_Flow() async throws {
        // 사진을 선택 불가능한 경우
        
        let store = TestStore(
            initialState: Counseling.State(
                maxSelectionLimit: 0,
                title: "",
                weather: .sunny,
                emoji: .happy,
                character: .chan,
                selections: []
            )) {
                Counseling()
            }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapPicker))
        await store.finish()
    }
    
    @Test
    func 보내기_버튼을_누르는_Flow() async throws {
        // 내용을 작성하고 보내기 버튼을 누르는 경우
        
        let store = TestStore(
            initialState: Counseling.State(
                maxSelectionLimit: 0,
                title: "",
                weather: .sunny,
                emoji: .happy,
                character: .chan,
                selections: []
            )) {
                Counseling()
            }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapSendingButton))
        await store.receive(.delegate(.navigateToResult(.chan)))
    }
    
    @Test
    func 내용을_작성하는_Flow() async throws {
        let store = TestStore(
            initialState: Counseling.State(
                maxSelectionLimit: 0,
                title: "",
                weather: .sunny,
                emoji: .happy,
                character: .chan,
                selections: [],
                letterText: ""
            )) {
                Counseling()
            }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didEnterText("hello"))) {
            $0.letterText = "hello"
        }
    }
    
    @Test
    func 사진_추가_Flow() async throws {
        let store = TestStore(
            initialState: Counseling.State(
                maxSelectionLimit: 0,
                title: "",
                weather: .sunny,
                emoji: .happy,
                character: .chan,
                selections: [],
                letterText: ""
            )) {
                Counseling()
            } withDependencies: {
                $0.uuid = .incrementing
            }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didAppendImages([.init(image: UIImage(), thumbnailImage: UIImage())]))) {
            #expect($0.selections.count == 1)
        }
    }
    
    @Test
    func 사진_교체_Flow() async throws {
        let store = TestStore(
            initialState: Counseling.State(
                title: "",
                weather: .sunny,
                emoji: .happy,
                character: .chan,
                selections: []
            )) {
                Counseling()
            } withDependencies: {
                $0.uuid = .incrementing
            }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(
            .view(
                .didAppendImages(
                    [.init(image: UIImage(), thumbnailImage: UIImage()),
                     .init(image: UIImage(), thumbnailImage: UIImage()),
                     .init(image: UIImage(), thumbnailImage: UIImage())]
                )
            )
        )
        
        await store.send(.view(.didUpdateSelection([.init(uuid: UUID(10), image: UIImage(), thumbnailImage: UIImage())]))) {
            #expect($0.selections.count == 1)
            #expect($0.selections[0].uuid == UUID(10))
        }
    }
    
    @Test
    func 사진_삭제_Flow() async throws {
        let store = TestStore(
            initialState: Counseling.State(
                title: "",
                weather: .sunny,
                emoji: .happy,
                character: .chan,
                selections: []
            )) {
                Counseling()
            } withDependencies: {
                $0.uuid = .incrementing
            }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(
            .view(
                .didAppendImages(
                    [.init(image: UIImage(), thumbnailImage: UIImage()),
                     .init(image: UIImage(), thumbnailImage: UIImage())]
                )
            )
        )
        
        await store.send(.view(.didRemoveSelection(UUID(0)))) {
            #expect($0.selections.count == 1)
            #expect($0.selections[0].uuid == UUID(1))
        }
    }
}
