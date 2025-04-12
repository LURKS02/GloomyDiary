//
//  TutorialNavigationController.swift
//  GloomyDiary
//
//  Created by 디해 on 2/17/25.
//

import ComposableArchitecture
import UIKit

final class TutorialNavigationController: NavigationStackController {
    
    private var store: StoreOf<TutorialNavigation>!
    
    convenience init(store: StoreOf<TutorialNavigation>) {
        @UIBindable var store = store
        
        self.init(path: $store.scope(state: \.path, action: \.path)) {
            let vc = WelcomeViewController(store: store.scope(state: \.welcome, action: \.welcome))
            return vc
        } destination: { store in
            switch store.case {
            case .guide(let store):
                GuideViewController(store: store)
            case .startCounsel(let store):
                StartCounselViewController(store: store)
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
