//
//  ReviewViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/27/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class ReviewViewController: BaseViewController<ReviewView> {
    
    @UIBindable var store: StoreOf<Review>
    
    private let backgroundTap = UITapGestureRecognizer()
    
    init(store: StoreOf<Review>) {
        self.store = store
        let contentView = ReviewView(character: CounselingCharacter.getRandomElement())
        super.init(contentView)
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

private extension ReviewViewController {
    func bind() {
        contentView.blurView
            .addGestureRecognizer(backgroundTap)
        
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
                guard let self else { return }
                store.send(.view(.didTapBackground))
            }
            .store(in: &cancellables)
        
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

        observe { [weak self] in
            guard let self else { return }
            
            if store.prepareForDismiss {
                animateBeforeDismiss()
            }
        }
    }
}
