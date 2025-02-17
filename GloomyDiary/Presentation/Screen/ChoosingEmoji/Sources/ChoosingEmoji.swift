//
//  ChoosingEmoji.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChoosingEmoji {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var emoji: Emoji?
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapEmoji(identifier: String)
        case didTapNextButton
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case navigateToCharacterSelection
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapEmoji(let identifier):
                    guard let emoji = Emoji(identifier: identifier) else { return .none }
                    state.emoji = emoji
                    logger.send(.tapped, "감정 버튼을 눌렀습니다.", ["감정": identifier])
                    return .none
                    
                case .didTapNextButton:
                    guard state.emoji != nil else { return .none }
                    
                    return .run { send in
                        await send(.delegate(.navigateToCharacterSelection))
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
