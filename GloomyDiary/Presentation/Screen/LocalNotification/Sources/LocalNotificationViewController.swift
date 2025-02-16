//
//  LocalNotificationViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/28/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class LocalNotificationViewController: BaseViewController<LocalNotificationView> {
    
    let store: StoreOf<LocalNotification>
    
    init(store: StoreOf<LocalNotification>) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task { @MainActor in
            await contentView.runAppearanceAnimation()
        }
    }
    
    func animateBeforeDismiss() {
        Task { @MainActor in
            await contentView.runDismissAnimation()
            store.send(.view(.dismiss))
        }
    }
}

private extension LocalNotificationViewController {
    func bind() {
        contentView.rejectButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                store.send(.view(.didTapRejectButton))
            }
            .store(in: &cancellables)
        
        contentView.acceptButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                store.send(.view(.didTapAcceptButton))
            }
            .store(in: &cancellables)
        
        contentView.checkButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                store.send(.view(.didTapCheckButton))
            }
            .store(in: &cancellables)
        
        
        observe { [weak self] in
            guard let self else { return }
            
            if store.prepareForDismiss {
                animateBeforeDismiss()
            }
            
            if let result = store.state.notificationResult {
                switch result {
                case .accept:
                    switchToAccept()
                case .reject:
                    switchToReject()
                case .show:
                    showNotificationPopUp()
                }
            }
        }
    }
    
    func switchToAccept() {
        Task { @MainActor in
            await self.contentView.runFadeOutLeftAnimation()
            await self.contentView.showAcceptResult()
        }
    }
    
    func switchToReject() {
        Task { @MainActor in
            await self.contentView.runFadeOutLeftAnimation()
            await self.contentView.showRejectResult()
        }
    }
    
    func showNotificationPopUp() {
        Task { @MainActor in
            let userAccepted = await LocalNotificationService.shared.requestNotificationPermission()
            
            if userAccepted {
                self.store.send(.view(.didAcceptNotification))
            } else {
                self.store.send(.view(.didRejectNotification))
            }
        }
    }
}
