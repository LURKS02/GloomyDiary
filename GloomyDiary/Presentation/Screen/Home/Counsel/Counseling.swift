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
    @ObservableState
    struct State: Equatable {
        let title: String
        let weatherIdentifier: String
        let emojiIdentifier: String
        let character: CounselingCharacter
        var urls: [URL] = []
    }
    
    enum Action {
        case selectedImageURLs([URL])
        case updateImageURLs([URL])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .selectedImageURLs(let urls):
                state.urls += urls
                return .none
                
            case .updateImageURLs(let urls):
                state.urls = urls
                return .none
            }
        }
    }
}
