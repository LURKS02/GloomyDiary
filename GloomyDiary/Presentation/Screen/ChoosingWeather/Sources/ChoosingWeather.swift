//
//  ChoosingWeather.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChoosingWeather {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var weather: Weather?
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapWeatherButton(identifier: String)
        case didTapNextButton
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case navigateToEmojiSelection
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapWeatherButton(let identifier):
                    guard let weather = Weather(identifier: identifier) else { return .none }
                    state.weather = weather
                    logger.send(.tapped, "날씨 버튼을 눌렀습니다.", ["날씨": identifier])
                    return .none
                    
                case .didTapNextButton:
                    guard state.weather != nil else { return .none }
                    
                    return .run { send in
                        await send(.delegate(.navigateToEmojiSelection))
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
