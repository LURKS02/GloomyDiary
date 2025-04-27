//
//  DeleteViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 12/16/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class DeleteViewController: BaseViewController<DeleteView> {
    
    @UIBindable var store: StoreOf<HistoryDelete>
    
    
    // MARK: - Properties

    private let backgroundTap = UITapGestureRecognizer()
    
    
    // MARK: - Initialize

    init(store: StoreOf<HistoryDelete>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
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


// MARK: - bind

private extension DeleteViewController {
    func bind() {
        contentView.backgroundView.addGestureRecognizer(backgroundTap)
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.contentView.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        backgroundTap.tapPublisher
            .sink { [weak self] _ in
                self?.store.send(.view(.didTapBackground))
            }
            .store(in: &cancellables)
        
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
            
            contentView.configure(character: store.counselor)
            
            if store.prepareForDismiss {
                Task {
                    await self.contentView.playFadeOutAnimation()
                    self.store.send(.view(.dismiss(self.store.flag)))
                }
            }
        }
    }
}
