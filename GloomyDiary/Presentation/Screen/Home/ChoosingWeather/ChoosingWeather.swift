//
//  ChoosingWeather.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChoosingWeather {
    @ObservableState
    struct State: Equatable {
        let title: String
        var weatherIdentifier: String?
        var isSendable: Bool = false
    }
    
    enum Action {
        case weatherTapped(identifier: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .weatherTapped(let identifier):
                state.weatherIdentifier = identifier
                state.isSendable = true
                return .none
            }
        }
    }
}
