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
        let character: CharacterDTO
        var images: [UIImage] = []
    }
    
    enum Action {
        case selectedImages([UIImage])
        case updateImages([UIImage])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .selectedImages(let images):
                state.images += images
                return .none
                
            case .updateImages(let images):
                state.images = images
                return .none
            }
        }
    }
}
