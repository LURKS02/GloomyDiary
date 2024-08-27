//
//  Choosing.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Choosing {
    @ObservableState
    struct State: Equatable {
        var firstIntroduceText: String = ""
        var secondIntroduceText: String = ""
        var characterIntroduceText: String = ""
        var chosenCharacter: Character? = nil
    }
    
    enum Action {
        case initialize(Bool)
        case characterTapped(character: Character)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize(let isFirstConsultation):
                if isFirstConsultation {
                    state.firstIntroduceText = "첫 번째 상담을 진행해볼까요?"
                    state.secondIntroduceText = "\"울다\"에는\n여러분들의 이야기를 들려줄\n세 마리의 상담사가 있어요."
                } else {
                    state.firstIntroduceText = "반가워요!"
                    state.secondIntroduceText = "오늘은 어떤 일이 있었나요?\n당신의 이야기를 들려주세요."
                }
                
                state.characterIntroduceText = "상담하고 싶은 친구를\n선택해주세요."
                return .none
                
            case .characterTapped(let character):
                state.chosenCharacter = character
                state.characterIntroduceText = character.introduce
                return .none
            }
        }
    }
}
