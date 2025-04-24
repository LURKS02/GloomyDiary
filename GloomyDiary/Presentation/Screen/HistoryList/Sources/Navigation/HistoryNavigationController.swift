//
//  HistoryNavigationController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/3/25.
//

import ComposableArchitecture
import UIKit

final class HistoryNavigationController: NavigationStackController {
    private var store: StoreOf<HistoryNavigation>!
    
    convenience init(store: StoreOf<HistoryNavigation>) {
        @UIBindable var store = store
        
        self.init(path: $store.scope(state: \.path, action: \.path)) {
            let vc = HistoryViewController(store: store.scope(state: \.history, action: \.history))
            return vc
        } destination: { store in
            switch store.case {
            case .detail(let store):
                HistoryDetailViewController(store: store)
            }
        }
        
        self.store = store
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = self.navigationBar.standardAppearance
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.Background.historyCell.color
        appearance.shadowColor = .clear
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        
        self.interactivePopGestureRecognizer?.isEnabled = true
        self.interactivePopGestureRecognizer?.delegate = self
        
        bind()
    }
    
    private func bind() {
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                UIView.animate(withDuration: 0.2) {
                    let appearance = self.navigationBar.standardAppearance
                    appearance.backgroundColor = AppColor.Background.historyCell.color
                    self.navigationBar.standardAppearance = appearance
                    self.navigationBar.scrollEdgeAppearance = appearance
                    
                    self.navigationBar.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefreshWithoutAnimation)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let appearance = self.navigationBar.standardAppearance
                appearance.backgroundColor = AppColor.Background.historyCell.color
                self.navigationBar.standardAppearance = appearance
                self.navigationBar.scrollEdgeAppearance = appearance
            }
            .store(in: &cancellables)
    }
}

extension HistoryNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
