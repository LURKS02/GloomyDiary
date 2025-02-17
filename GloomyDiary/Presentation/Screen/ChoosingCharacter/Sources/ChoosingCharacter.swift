//
//  ChoosingCharacter.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChoosingCharacter {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        var character: CounselingCharacter = .chan
        var page: Int = 0
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapCharacter(identifier: String)
        case didScrollToPage(Int)
        case didTapNextButton
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case navigateToCounsel(CounselingCharacter)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapCharacter(let identifier):
                    guard let character = CounselingCharacter(identifier: identifier),
                          let index = CounselingCharacter.allCases.firstIndex(where: { $0.identifier == identifier })
                    else { return .none }
                    
                    logger.send(.tapped, "캐릭터 버튼을 눌렀습니다.", ["캐릭터": identifier])
                    state.character = character
                    state.page = index
                    return .none
                    
                case .didScrollToPage(let page):
                    state.character = CounselingCharacter.allCases[page]
                    state.page = page
                    
                    return .none
                    
                case .didTapNextButton:
                    let character = state.character
                    return .run { send in
                        await send(.delegate(.navigateToCounsel(character)))
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
