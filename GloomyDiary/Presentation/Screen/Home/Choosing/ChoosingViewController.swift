//
//  ChoosingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit
import ComposableArchitecture

final class ChoosingViewController: BaseViewController<ChoosingView> {
    let store: StoreOf<Choosing>
    
    init(store: StoreOf<Choosing>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - View Controller Life Cycle

extension ChoosingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addCharactersToStack(Character.allCases)
        contentView.hideAllComponents()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await contentView.playFadeInAllComponents()
            contentView.enableAllCharacterButtons()
        }
    }
}


// MARK: - bind

private extension ChoosingViewController {
    func bind() {
        contentView.allCharacterButtons.forEach { button in
            button.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    self?.contentView.allCharacterButtons
                        .forEach { $0.isSelected = false }
                    
                    button.isSelected = true
                    self?.contentView.enableCounselButton()
                    guard let bound = button.getCharacterFrame() else { return }
                    
                    self?.store.send(.characterTapped(tag: button.tag))
                })
                .disposed(by: disposeBag)
        }
        
        contentView.counselButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let chosenCharacter = self?.store.chosenCharacter else { return }
                let store: StoreOf<Counseling> = Store(initialState: .init(character: chosenCharacter), reducer: { Counseling() })
                let counselingViewController = CounselingViewController(store: store)
                self?.navigationController?.delegate = self
                self?.navigationController?.pushViewController(counselingViewController,
                                                                   animated: true)
            })
            .disposed(by: disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.setCharacterIntroduceMessage(character: store.chosenCharacter)
            
            self.contentView.setMessage(isFirst: store.isFirst)
        }
    }
}

extension ChoosingViewController {
    func getCharacterFrame() -> CGRect? {
        guard let selectedButton = contentView.allCharacterButtons.filter({ $0.isSelected }).first else { return nil }
        guard let frame = selectedButton.getCharacterFrame() else { return nil }
        return contentView.convert(frame, from: selectedButton)
    }
}

extension ChoosingViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ChoosingTransition()
    }
}
