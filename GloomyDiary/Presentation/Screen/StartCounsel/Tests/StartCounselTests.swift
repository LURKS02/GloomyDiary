//
//  StartCounselTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/14/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiaryExample

@MainActor
struct StartCounselTests {
    @Test
    func 첫_편지쓰기_판별_Flow() async throws {
        // isFirstProcess == true
        // 첫 편지쓰기인 경우
        
        let store = TestStore(
            initialState: StartCounsel.State()
        ) {
            StartCounsel()
        } withDependencies: {
            let mock = MockUserData()
            mock.data[\.isFirstProcess] = true
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidLoad)) {
            $0.isFirstProcess = true
        }
    }
    
    @Test
    func 첫_편지쓰기가_아닌_경우_판별_Flow() async throws {
        // isFirstProcess == false
        // 첫 편지쓰기가 아닌 경우
        
        let store = TestStore(
            initialState: StartCounsel.State()
        ) {
            StartCounsel()
        } withDependencies: {
            let mock = MockUserData()
            mock.data[\.isFirstProcess] = false
            $0.userSetting = mock
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.viewDidLoad)) {
            $0.isFirstProcess = false
        }
    }
    
    @Test
    func 빈_문자열이_입력된_경우_Flow() async throws {
        // 빈 문자열이 입력된 경우
        
        let store = TestStore(
            initialState: StartCounsel.State()
        ) {
            StartCounsel()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didEnterText(""))) {
            $0.title = ""
        }
        await store.receive(.inner(.updateTextValidation(""))) {
            $0.isSendable = false
            $0.warning = ""
        }
    }
    
    @Test
    func 문자열이_공백으로_시작하는_경우_Flow() async throws {
        // 입력 문자열이 공백으로 시작하는 경우
        
        let store = TestStore(
            initialState: StartCounsel.State()
        ) {
            StartCounsel()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didEnterText(" "))) {
            $0.title = " "
        }
        await store.receive(.inner(.updateTextValidation(" "))) {
            $0.isSendable = false
            $0.warning = "올바르지 않은 형식이에요."
        }
    }
    
    @Test
    func 문자열_길이가_15글자를_초과하는_경우_Flow() async throws {
        // 문자열의 길이가 15글자 초과인 경우
        
        let store = TestStore(
            initialState: StartCounsel.State()
        ) {
            StartCounsel()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didEnterText("AAAAAAAAAAAAAAAA"))) {
            $0.title = "AAAAAAAAAAAAAAAA"
        }
        await store.receive(.inner(.updateTextValidation("AAAAAAAAAAAAAAAA"))) {
            $0.isSendable = false
            $0.warning = "15자 이하로 작성해주세요."
        }
    }
    
    @Test
    func 유효한_문자열을_보내는_경우_Flow() async throws {
        // 문자열이 공백으로 시작되지 않고, 길이가 15글자 이하인 경우
        
        let store = TestStore(
            initialState: StartCounsel.State()
        ) {
            StartCounsel()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didEnterText("제목"))) {
            $0.title = "제목"
        }
        await store.receive(.inner(.updateTextValidation("제목"))) {
            $0.isSendable = true
            $0.warning = ""
        }
    }
    
    @Test
    func 다음_화면으로_이동_가능_Flow() async throws {
        // isSendable == true
        // 전송 가능한 제목을 가지고 있을 때, 다음 버튼을 누르는 경우
        
        let store = TestStore(
            initialState: StartCounsel.State(
                isSendable: true
            )
        ) {
            StartCounsel()
        }
        store.exhaustivity = .off
        
        // MARK: - Flow Start
        await store.send(.view(.didTapNextButton))
        await store.receive(.delegate(.navigateToWeatherSelection))
    }
}
