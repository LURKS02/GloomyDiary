//
//  Guide.swift
//  GloomyDiary
//
//  Created by 디해 on 2/17/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Guide {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: FeatureAction, Equatable {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
    }
    
    enum ViewAction: Equatable {}
    
    enum InnerAction: Equatable {}
    
    enum ScopeAction: Equatable {}
    
    enum DelegateAction: Equatable {
        case navigateToStartCounsel
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            }
        }
    }
}
