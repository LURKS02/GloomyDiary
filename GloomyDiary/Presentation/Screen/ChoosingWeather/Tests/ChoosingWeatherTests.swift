//
//  ChoosingWeatherTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 2/14/25.
//

import ComposableArchitecture
import Testing

@testable import GloomyDiary

@MainActor
struct ChoosingWeatherTests {
    @Test
    func 날씨_첫_선택_Flow() async throws {
        // weather == nil
        // 날씨를 선택한 적이 없을 때, 날씨를 고르는 경우
        
        let store = TestStore(
            initialState: ChoosingWeather.State(
                weather: nil
            )
        ) {
            ChoosingWeather()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapWeatherButton(identifier: "sunny"))) {
            $0.weather = .sunny
        }
    }

    @Test
    func 날씨_변경_Flow() async throws {
        // weather == "sunny"
        // 날씨를 선택한 적이 있을 때, 날씨를 고르는 경우
        
        let store = TestStore(
            initialState: ChoosingWeather.State(
                weather: .sunny
            )
        ) {
            ChoosingWeather()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapWeatherButton(identifier: "cloudy"))) {
            $0.weather = .cloudy
        }
    }
    
    @Test
    func 다음_화면으로_이동_가능_Flow() async throws {
        // weather != nil
        // 날씨를 골랐을 때, 다음 버튼을 누르는 경우
        
        let store = TestStore(
            initialState: ChoosingWeather.State(
                weather: .sunny
            )
        ) {
            ChoosingWeather()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapNextButton))
        await store.receive(.delegate(.navigateToEmojiSelection))
    }
    
    @Test
    func 다음_화면으로_이동_불가능_Flow() async throws {
        // weather == nil
        // 날씨를 고르지 않았을 때, 다음 버튼을 누르는 경우
        
        let store = TestStore(
            initialState: ChoosingWeather.State(
                weather: nil
            )
        ) {
            ChoosingWeather()
        }
        
        // MARK: - Flow Start
        await store.send(.view(.didTapNextButton))
        await store.finish()
    }
}
