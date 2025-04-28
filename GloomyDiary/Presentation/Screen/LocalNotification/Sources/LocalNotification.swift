//
//  LocalNotification.swift
//  GloomyDiary
//
//  Created by 디해 on 2/2/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct LocalNotification {
    @Dependency(\.userSetting) var userSetting
    @Dependency(\.logger) var logger
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable {
        var prepareForDismiss: Bool = false
        var notificationResult: NoficiationRequestResult?
        
        enum NoficiationRequestResult {
            case show
            case accept
            case reject
        }
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapRejectButton
        case didTapAcceptButton
        case didTapCheckButton
        case didAcceptNotification
        case didRejectNotification
        case dismiss
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {}
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapRejectButton:
                    logger.send(.tapped, "거절 버튼을 눌러 알람을 거절했습니다.", nil)
                    state.notificationResult = .reject
                    return .none
                    
                case .didTapAcceptButton:
                    logger.send(.tapped, "승인을 눌러 알람 설정 창을 표시합니다.", nil)
                    state.notificationResult = .show
                    return .none
                    
                case .didTapCheckButton:
                    try? userSetting.update(keyPath: \.hasSuggestedNotification, value: true)
                    state.prepareForDismiss = true
                    return .none
                    
                case .didAcceptNotification:
                    logger.send(.tapped, "승인 버튼을 눌러 알람을 승인했습니다.", nil)
                    state.notificationResult = .accept
                    return .none
                    
                case .didRejectNotification:
                    logger.send(.tapped, "거절 버튼을 눌러 알람을 거절했습니다.", nil)
                    state.notificationResult = .reject
                    return .none
                    
                case .dismiss:
                    return .run { send in
                        await dismiss()
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
