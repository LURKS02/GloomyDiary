//
//  Setting.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Setting {
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
    }
    
    enum InnerAction: Equatable {
    }
    
    enum ScopeAction: Equatable {
    }
    
    enum DelegateAction: Equatable {}
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
