//
//  ChoosingCharacterViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class ChoosingCharacterViewController: BaseViewController<ChoosingCharacterView> {
    
    let store: StoreOf<ChoosingCharacter>
    
    
    // MARK: - Initialize

    init(store: StoreOf<ChoosingCharacter>) {
        self.store = store
        super.init()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.delegate = self
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

extension ChoosingCharacterViewController {
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
        
        contentView.allCharacterButtons.forEach { button in
            button.tapPublisher
                .sink { [weak self] in
                    guard let self else { return }
                    store.send(.view(.didTapCharacter(identifier: button.identifier)))
                }
                .store(in: &cancellables)
        }
        
        contentView.nextButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                store.send(.view(.didTapNextButton))
            }
            .store(in: &cancellables)
        
        contentView.pageSubject
            .sink { [weak self] page in
                guard let self else { return }
                store.send(.view(.didScrollToPage(page)))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.switchToPage(store.page)
            self.contentView.spotlight(to: store.character.identifier)
            self.contentView.detailInformationLabel.text = store.character.introduceMessage
        }
    }
}


// MARK: - Transition

extension ChoosingCharacterViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        contentView.allCharacterButtons.first(where: { $0.isSelected })?.imageView
    }
    
    func prepareTransition(duration: TimeInterval) async {
        await contentView.playFadeOutAllComponents(duration: duration)
    }
}

extension ChoosingCharacterViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        await contentView.playFadeInAllComponents(duration: duration)
    }
}

extension ChoosingCharacterViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            contentDuration: 2.5,
            toDuration: 0.5,
            transitionContentType: .frameTransitionWithLottie(store.character)
        )
    }
}
