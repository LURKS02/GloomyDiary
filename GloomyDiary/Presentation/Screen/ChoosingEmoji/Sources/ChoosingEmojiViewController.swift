//
//  ChoosingEmojiViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class ChoosingEmojiViewController: BaseViewController<ChoosingEmojiView> {
    
    let store: StoreOf<ChoosingEmoji>
    
    
    // MARK: - Initialize

    init(store: StoreOf<ChoosingEmoji>) {
        self.store = store
        super.init()
        
        self.navigationItem.hidesBackButton = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        contentView.hideAllComponents()
        
        self.navigationController?.delegate = self
    }
}


// MARK: - bind

extension ChoosingEmojiViewController {
    private func bind() {
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.contentView.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        contentView.allEmojiButtons.forEach { button in
            button.tapPublisher
                .sink { [weak self] in
                    guard let self else { return }
                    store.send(.view(.didTapEmoji(identifier: button.identifier)))
                }
                .store(in: &cancellables)
        }
        
        contentView.allEmojiButtons.forEach { button in
            button.controlEventPublisher(for: .touchUpOutside)
                .sink { [weak self] in
                    guard let self else { return }
                    contentView.spotlight(to: store.emoji?.identifier)
                }
                .store(in: &cancellables)
        }
        
        contentView.nextButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                store.send(.view(.didTapNextButton))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.spotlight(to: store.emoji?.identifier)
            self.contentView.nextButton.isEnabled = (store.emoji != nil)
        }
    }
}


// MARK: - TransitionAnimation

extension ChoosingEmojiViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        await contentView.playFadeOutAllComponents()
    }
}

extension ChoosingEmojiViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        await contentView.playFadeInAllComponents(duration: duration)
    }
}

extension ChoosingEmojiViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            toDuration: 2.0,
            transitionContentType: .normalTransition
        )
    }
}
