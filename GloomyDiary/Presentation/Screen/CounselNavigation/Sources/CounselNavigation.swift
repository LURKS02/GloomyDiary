//
//  CounselNavigation.swift
//  GloomyDiary
//
//  Created by 디해 on 2/17/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CounselNavigation {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var counsel = StartCounsel.State()
    }
    
    @CasePathable
    enum Action: Equatable {
        case path(StackActionOf<Path>)
        case counsel(StartCounsel.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.counsel, action: \.counsel) {
            StartCounsel()
        }
        
        Reduce { state, action in
            switch action {
            case .counsel(.delegate(.navigateToWeatherSelection)):
                logger.send(.tapped, "편지 쓰기: 다음을 눌러 날씨 화면으로 이동합니다.", nil)
                state.path.append(.selectWeather(.init()))
                return .none
                
            case .counsel:
                return .none
                
            case .path(.element(id: _, action: .selectWeather(.delegate(.navigateToEmojiSelection)))):
                logger.send(.tapped, "편지 쓰기: 다음 버튼을 눌러 기분 선택 화면으로 이동합니다.", nil)
                state.path.append(.selectEmoji(.init()))
                return .none
                
            case .path(.element(id: _, action: .selectEmoji(.delegate(.navigateToCharacterSelection)))):
                logger.send(.tapped, "편지 쓰기: 다음 버튼을 눌러 캐릭터 선택 화면으로 이동합니다.", nil)
                state.path.append(.selectCharacter(.init()))
                return .none
                
            case .path(.element(id: _, action: .selectCharacter(.delegate(.navigateToCounsel(let character))))):
                logger.send(.tapped, "편지 쓰기: 다음 버튼을 눌러 편지 내용 작성 화면으로 이동합니다.", ["선택한 캐릭터": character.identifier])
                
                var weather: Weather?
                var emoji: Emoji?
                
                for id in state.path.ids {
                    if let selectedWeather = state.path[id: id, case: \.selectWeather]?.weather {
                        weather = selectedWeather
                    }
                    if let selectedEmoji = state.path[id: id, case: \.selectEmoji]?.emoji {
                        emoji = selectedEmoji
                    }
                }
                
                guard let weather, let emoji else { return .none }
                
                state.path.append(
                    .counseling(
                        .init(
                            title: state.counsel.title,
                            weather: weather,
                            emoji: emoji,
                            character: character
                        )
                    )
                )
                return .none
                
            case .path(.element(id: _, action: .counseling(.delegate(.navigateToResult(let counselor))))):
                logger.send(.tapped, "편지 쓰기: 편지를 전송하고 답장을 확인합니다.", nil)
                state.path.append(.result(.init(counselor: counselor)))
                return .none
                
            case .path(.element(id: _, action: .result(.delegate(.dismiss)))):
                return .run { _ in
                    await dismiss()
                }
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension CounselNavigation {
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case selectWeather(ChoosingWeather)
        case selectEmoji(ChoosingEmoji)
        case selectCharacter(ChoosingCharacter)
        case counseling(Counseling)
        case result(CounselResult)
    }
}
