//
//  Counseling.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import UIKit
import ComposableArchitecture

@Reducer
struct Counseling {
    @Dependency(\.logger) var logger
    
    @ObservableState
    struct State: Equatable {
        @Presents var picker: Picker.State?
        
        let maxImageLimit: Int = 10
        let title: String
        let weather: Weather
        let emoji: Emoji
        let character: CounselingCharacter
        var imageIDs: [UUID] = []
        var letterText: String = ""
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
        case didUpdateImageIDs([UUID])
    }
    
    enum InnerAction: Equatable {}
    
    @CasePathable
    enum ScopeAction: Equatable {
        case picker(PresentationAction<Picker.Action>)
        case didFinishPicker([UUID])
    }
    
    enum DelegateAction: Equatable {
        case navigateToResult
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapPicker:
                    guard state.imageIDs.count < state.maxImageLimit else { return .none }
                    
                    state.picker = .init(selectionLimit: state.maxImageLimit - state.imageIDs.count, selectedIDs: state.imageIDs)
                    return .none
                    
                case .didTapSendingButton:
                    return .run { send in
                        await send(.delegate(.navigateToResult))
                    }
                    
                case .didEnterText(let text):
                    state.letterText = text
                    return .none
                    
                case .didUpdateImageIDs(let ids):
                    state.imageIDs = ids
                    return .none
                }
                
            case .scope(.picker(.dismiss)):
                if let state = state.picker {
                    return .run { send in
                        await send(.scope(.didFinishPicker(state.selectedIDs)))
                    }
                }
                
                return .none
                
            case .scope(.didFinishPicker(let ids)):
                state.imageIDs = ids
                return .none
                
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
