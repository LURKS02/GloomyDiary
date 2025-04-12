//
//  HistoryMenuViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 12/15/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class HistoryMenuViewController: BaseViewController<HistoryDetailMenuView> {
    
    @UIBindable var store: StoreOf<HistoryMenu>
    
    // MARK: - Properties
    
    private let backgroundTap = UITapGestureRecognizer()
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<HistoryMenu>, navigationControllerHeight: CGFloat) {
        self.store = store
        let contentView = HistoryDetailMenuView(navigationControllerHeight: navigationControllerHeight)
        
        super.init(contentView)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.configure(with: [.share, .delete])
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await contentView.playFadeInAnimation()
        }
    }
}


// MARK: - bind

private extension HistoryMenuViewController {
    func bind() {
        contentView.backgroundView.addGestureRecognizer(backgroundTap)
        
        for button in contentView.menuButtons {
            button.tapPublisher
                .sink { [weak self] in
                    self?.store.send(.view(.didTapMenuButton(button.item)))
                }
                .store(in: &cancellables)
        }
        
        backgroundTap.tapPublisher
            .sink { [weak self] _ in
                self?.store.send(.view(.didTapBackground))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            if store.prepareForDismiss {
                Task {
                    await self.contentView.playFadeOutAnimation()
                    self.store.send(.view(.dismiss(self.store.flag)))
                }
            }
        }
    }
}
