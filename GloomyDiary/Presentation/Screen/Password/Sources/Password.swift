//
//  Password.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Password {
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {
        case didTapBackButton
    }
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {}
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .didTapBackButton:
                    return .run { _ in
                        await dismiss()
                    }
                }
            }
        }
    }
}
