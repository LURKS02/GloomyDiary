//
//  StartCounseling.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct StartCounsel {
    @Dependency(\.logger) var logger
    @Dependency(\.userSetting) var userSetting
    
    @ObservableState
    struct State: Equatable {
        var title: String = ""
        var isFirstProcess: Bool = true
        var isSendable: Bool = false
        var warning: String = ""
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case viewDidLoad
        case didEnterText(String)
        case didTapNextButton
    }
    
    enum InnerAction: Equatable {
        case updateTextValidation(String)
    }
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case navigateToWeatherSelection
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .viewDidLoad:
                    let isFirstProcess = userSetting.get(keyPath: \.isFirstProcess)
                    state.isFirstProcess = isFirstProcess
                    return .none
                    
                case .didEnterText(let text):
                    state.title = text
                    
                    return .run { send in
                        await send(.inner(.updateTextValidation(text)))
                    }
                    
                case .didTapNextButton:
                    guard state.isSendable else { return .none }
                    
                    return .run { send in
                        await send(.delegate(.navigateToWeatherSelection))
                    }
                }
                
            case .inner(let innerAction):
                switch innerAction {
                case .updateTextValidation(let text):
                    if text.count == 0 {
                        state.isSendable = false
                        state.warning = ""
                    } else if !text.isValidContent {
                        state.isSendable = false
                        state.warning = "올바르지 않은 형식이에요."
                    } else if text.count > 15 {
                        state.isSendable = false
                        state.warning = "15자 이하로 작성해주세요."
                    } else {
                        state.isSendable = true
                        state.warning = ""
                    }
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
