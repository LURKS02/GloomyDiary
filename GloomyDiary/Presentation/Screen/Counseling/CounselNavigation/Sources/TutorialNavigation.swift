//
//  TutorialNavigation.swift
//  GloomyDiary
//
//  Created by 디해 on 2/16/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct TutorialNavigation {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var welcome = Welcome.State()
    }
    
    @CasePathable
    enum Action: Equatable {
        case path(StackActionOf<Path>)
        case welcome(Welcome.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.welcome, action: \.welcome) {
            Welcome()
        }
        
        Reduce { state, action in
            switch action {
            case .welcome(.delegate(.navigateToGuide)):
                logger.send(.tapped, "튜토리얼: 유령을 눌러 가이드 화면으로 이동합니다.", nil)
                state.path.append(.guide(.init()))
                return .none
                
            case .welcome:
                return .none
                
            case .path(.element(id: _, action: .guide(.delegate(.navigateToStartCounsel)))):
                logger.send(.tapped, "튜토리얼: 화면을 눌러 편지 쓰기 시작 화면으로 이동합니다.", nil)
                state.path.append(.startCounsel(.init()))
                return .none
                
            case .path(.element(id: _, action: .startCounsel(.delegate(.navigateToWeatherSelection)))):
                logger.send(.tapped, "편지 쓰기: 다음을 눌러 날씨 화면으로 이동합니다.", nil)
                state.path.append(.selectWeather(.init()))
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
                
                var title: String?
                var weather: Weather?
                var emoji: Emoji?
                
                for id in state.path.ids {
                    if let text = state.path[id: id, case: \.startCounsel]?.title {
                        title = text
                    }
                    
                    if let selectedWeather = state.path[id: id, case: \.selectWeather]?.weather {
                        weather = selectedWeather
                    }
                    if let selectedEmoji = state.path[id: id, case: \.selectEmoji]?.emoji {
                        emoji = selectedEmoji
                    }
                }
                
                guard let title, let weather, let emoji else { return .none }
                
                state.path.append(
                    .counseling(
                        .init(
                            title: title,
                            weather: weather,
                            emoji: emoji,
                            character: character
                        )
                    )
                )
                return .none
                
            case .path(.element(id: _, action: .counseling(.delegate(.navigateToResult)))):
                var character: CounselingCharacter?
                var letterText: String?
                
                for id in state.path.ids {
                    if let selectedCharacter = state.path[id: id, case: \.selectCharacter]?.character {
                        character = selectedCharacter
                    }
                    if let text = state.path[id: id, case: \.counseling]?.letterText {
                        letterText = text
                    }
                }
                
                guard let character,
                      let letterText else { return .none }
                
                logger.send(.tapped, "편지 쓰기: 편지를 전송하고 답장을 확인합니다.", nil)
                state.path.append(.result(.init(character: character, request: letterText)))
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension TutorialNavigation {
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case guide(Guide)
        case startCounsel(StartCounsel)
        case selectWeather(ChoosingWeather)
        case selectEmoji(ChoosingEmoji)
        case selectCharacter(ChoosingCharacter)
        case counseling(Counseling)
        case result(CounselResult)
    }
}
