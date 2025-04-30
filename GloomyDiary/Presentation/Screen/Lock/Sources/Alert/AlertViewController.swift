//
//  AlertViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import ComposableArchitecture
import UIKit

final class AlertViewController: BaseViewController<AlertView> {
    
    @UIBindable var store: StoreOf<Alert>
    
    init(store: StoreOf<Alert>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { @MainActor in
            await contentView.playFadeInAnimation()
        }
    }
}

private extension AlertViewController {
    func bind() {
        contentView.rejectButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapRejectButton))
            }
            .store(in: &cancellables)
        
        contentView.acceptButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapAcceptButton))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            if store.prepareForDismiss {
                Task {
                    await self.contentView.playFadeOutAnimation()
                    self.store.send(.view(.dismiss))
                }
            }
        }
    }
}
