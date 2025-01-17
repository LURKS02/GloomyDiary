//
//  ChoosingEmojiViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit
import ComposableArchitecture

final class ChoosingEmojiViewController: BaseViewController<ChoosingEmojiView> {
    
    let store: StoreOf<ChoosingEmoji>
    
    @Dependency(\.logger) var logger
    
    
    // MARK: - Initialize

    init(store: StoreOf<ChoosingEmoji>) {
        self.store = store
        super.init(logID: "ChoosingEmoji")
        
        self.navigationItem.hidesBackButton = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
}


// MARK: - bind

extension ChoosingEmojiViewController {
    private func bind() {
        contentView.allEmojiButtons.forEach { button in
            button.rx.tap
                .do(onNext: { [weak self] _ in
                    let identifier = button.identifier
                    self?.logger.send(
                        .tapped,
                        "이모지 버튼",
                        ["이모지": identifier]
                    )
                })
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    store.send(.emojiTapped(identifier: button.identifier))
                })
                .disposed(by: rx.disposeBag)
        }
        
        contentView.allEmojiButtons.forEach { button in
            button.rx.controlEvent(.touchUpOutside)
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    contentView.spotlight(to: store.emojiIdentifier)
                })
                .disposed(by: rx.disposeBag)
        }
        
        contentView.nextButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.nextButton.title(for: .normal),
                      let selectedEmoji = self?.store.emojiIdentifier else { return }
                self?.logger.send(
                    .tapped,
                    title,
                    ["선택한 이모지": selectedEmoji]
                )
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let emojiIdentifier = store.emojiIdentifier else { return }
                navigateToCharacterSelection(with: emojiIdentifier)
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.spotlight(to: store.emojiIdentifier)
            
            self.contentView.nextButton.isEnabled = store.isSendable
        }
    }
}


// MARK: - Navigation

extension ChoosingEmojiViewController {
    func navigateToCharacterSelection(with emojiIdentifier: String) {
        let store: StoreOf<ChoosingCharacter> = Store(initialState: .init(title: store.title, weatherIdentifier: store.weatherIdenfitier, emojiIdentifier: emojiIdentifier), reducer: { ChoosingCharacter() })
        let choosingCharacterViewController = ChoosingCharacterViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(choosingCharacterViewController, animated: true)
    }
}



// MARK: - TransitionAnimation

extension ChoosingEmojiViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        PresentingTransition()
    }
}

extension ChoosingEmojiViewController: Presentable {
    func playAppearingAnimation() async {
        contentView.hideAllComponents()
        await contentView.playFadeInAllComponents()
    }
}

extension ChoosingEmojiViewController: PresentingDisappearable {
    func playDisappearingAnimation() async {
        await contentView.playFadeOutAllComponents()
    }
}
