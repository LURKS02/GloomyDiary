//
//  Counseling.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import ComposableArchitecture
import UIKit

@Reducer
struct Counseling {
    @Dependency(\.counselRepository) var counselRepository
    @Dependency(\.userSetting) var userSetting
    @Dependency(\.logger) var logger
    @Dependency(\.uuid) var uuid
    
    @ObservableState
    struct State: Equatable {
        @Presents var picker: Picker.State?

        var maxSelectionLimit: Int = 10
        let maxTextCount: Int = 300
        
        let title: String
        let weather: Weather
        let emoji: Emoji
        let character: CounselingCharacter
        var selections: [ImageSelection] = []
        var letterText: String = ""
        var textState: SendingTextState = .empty
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapPicker
        case didTapSendingButton
        case didEnterText(String)
        case didAppendImages([ImageSet])
        case didUpdateSelection([ImageSelection])
        case didRemoveSelection(UUID)
    }
    
    enum InnerAction: Equatable {}
    
    @CasePathable
    enum ScopeAction: Equatable {
        case picker(PresentationAction<Picker.Action>)
        case didFinishPicker([UUID])
    }
    
    enum DelegateAction: Equatable {
        case navigateToResult(CounselingCharacter)
    }
    
    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapPicker:
                    guard state.selections.count < state.maxSelectionLimit else { return .none }
                    
                    state.picker = .init(
                        selectionLimit: state.maxSelectionLimit - state.selections.count
                    )
                    
                    return .none
                    
                case .didTapSendingButton:
                    let counselor = state.character
                    
                    return .run { send in
                        await send(.delegate(.navigateToResult(counselor)))
                    }
                    
                case .didEnterText(let text):
                    state.letterText = text
                    
                    if text.count > state.maxTextCount {
                        state.textState = .max
                    } else if text.count == 0 {
                        state.textState = .empty
                    } else {
                        state.textState = .sendable
                    }
                    
                    return .none
                    
                case .didAppendImages(let imageSet):
                    let selections = imageSet.map { ImageSelection(
                        uuid: uuid(),
                        image: $0.image,
                        thumbnailImage: $0.thumbnailImage
                    )}
                    
                    state.selections += selections
                    return .none
                    
                case .didUpdateSelection(let selections):
                    state.selections = selections
                    return .none
                    
                case .didRemoveSelection(let id):
                    state.selections = state.selections.filter { $0.uuid != id }
                    return .none
                }
                
            case .scope:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$picker, action: \.scope.picker) {
            Picker()
        }
    }
}
