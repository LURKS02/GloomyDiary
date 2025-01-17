//
//  ChoosingCharacterViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import ComposableArchitecture
import Dependencies
import UIKit

final class ChoosingCharacterViewController: BaseViewController<ChoosingCharacterView> {
    
    let store: StoreOf<ChoosingCharacter>
    
    @Dependency(\.logger) var logger
    
    
    // MARK: - Initialize

    init(store: StoreOf<ChoosingCharacter>) {
        self.store = store
        super.init(logID: "ChoosingCharacter")
        
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

extension ChoosingCharacterViewController {
    private func bind() {
        contentView.allCharacterButtons.forEach { button in
            button.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    guard let page = contentView.allCharacterButtons.enumerated().compactMap({ (index, characterButton) in
                        characterButton.identifier == button.identifier ? index : nil
                    }).first else { return }
                    
                    contentView.switchToPage(page)
                })
                .disposed(by: rx.disposeBag)
        }
        
        contentView.nextButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.nextButton.title(for: .normal),
                      let selectedCharacter = self?.store.character.name else { return }
                self?.logger.send(
                    .tapped,
                    title,
                    ["선택한 캐릭터": selectedCharacter]
                )
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                navigateToLetter(with: store.character)
            })
            .disposed(by: rx.disposeBag)
        
        contentView.characterIdentifierRelay
            .do(onNext: { [weak self] identifier in
                self?.logger.send(
                    .tapped,
                    "캐릭터 선택",
                    ["캐릭터": identifier]
                )
            })
            .subscribe(onNext: { [weak self] identifier in
                guard let self else { return }
                store.send(.characterSelected(identifier: identifier))
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.spotlight(to: store.character.identifier)
            self.contentView.detailInformationLabel.text = store.character.introduceMessage
        }
    }
}


// MARK: - Navigation

extension ChoosingCharacterViewController {
    func navigateToLetter(with character: CounselingCharacter) {
        let store: StoreOf<Counseling> = Store(initialState: .init(title: store.title, weatherIdentifier: store.weatherIdentifier, emojiIdentifier: store.emojiIdentifier, character: store.character), reducer: { Counseling() })
        let counselingViewController = CounselingViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(counselingViewController, animated: true)
    }
}


// MARK: - TransitionAnimation

extension ChoosingCharacterViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ChoosingTransition()
    }
}

extension ChoosingCharacterViewController: Presentable {
    func playAppearingAnimation() async {
        contentView.hideAllComponents()
        await contentView.playFadeInAllComponents()
    }
}

extension ChoosingCharacterViewController: PresentingDisappearable {
    func playDisappearingAnimation() async {
        await contentView.playFadeOutAllComponents()
    }
}
