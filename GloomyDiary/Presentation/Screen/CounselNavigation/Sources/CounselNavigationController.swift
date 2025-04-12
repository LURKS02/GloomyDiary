//
//  CounselNavigationController.swift
//  GloomyDiary
//
//  Created by 디해 on 2/5/25.
//

import ComposableArchitecture
import UIKit

final class CounselNavigationController: NavigationStackController {
    
    private var store: StoreOf<CounselNavigation>!
    
    convenience init(store: StoreOf<CounselNavigation>) {
        @UIBindable var store = store
        
        self.init(path: $store.scope(state: \.path, action: \.path)) {
            let vc = StartCounselViewController(store: store.scope(state: \.counsel, action: \.counsel))
            vc.contentView.moonImageView.alpha = 1.0
            return vc
        } destination: { store in
            switch store.case {
            case .selectWeather(let store):
                ChoosingWeatherViewController(store: store)
            case .selectEmoji(let store):
                ChoosingEmojiViewController(store: store)
            case .selectCharacter(let store):
                ChoosingCharacterViewController(store: store)
            case .counseling(let store):
                CounselingViewController(store: store)
            case .result(let store):
                ResultViewController(store: store)
            }
        }
        
        self.store = store
    }
}
