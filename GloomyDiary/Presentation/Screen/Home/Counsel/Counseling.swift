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
        var imageIDs: [UUID] = []
    }
    
    enum Action {
        case selectedImageIDs([UUID])
        case updateImageIDs([UUID])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .selectedImageIDs(let ids):
                state.imageIDs += ids
                return .none
                
            case .updateImageIDs(let ids):
                state.imageIDs = ids
                return .none
            }
        }
    }
}
