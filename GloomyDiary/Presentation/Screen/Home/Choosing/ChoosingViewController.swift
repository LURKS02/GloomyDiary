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
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<Choosing>) {
        self.store = store
        let contentView = ChoosingView(isFirstProcess: store.isFirstProcess)
        super.init(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


// MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        contentView.hideAllComponents()
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
        contentView.allCharacterButtons.forEach { characterButton in
            characterButton.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    store.send(.characterTapped(identifier: characterButton.identifier))
                })
                .disposed(by: disposeBag)
        }
        
        contentView.counselButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let chosenCharacter = store.chosenCharacter else { return }
                navigateToCounseling(with: chosenCharacter)
            })
            .disposed(by: disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.spotlight(to: store.chosenCharacter)
        }
    }
}

// MARK: - Navigation

extension ChoosingViewController {
    func navigateToCounseling(with character: Character) {
        let store: StoreOf<Counseling> = Store(initialState: .init(character: character), reducer: { Counseling() })
        let aiService: AIServicable = ChatGPTService.shared
        let counselRepository: CounselRepositoryProtocol = CounselRepository(aiService: aiService)
        let counselingViewController = CounselingViewController(store: store, counselRepository: counselRepository)
        navigationController?.delegate = self
        navigationController?.pushViewController(counselingViewController,
                                                 animated: true)
    }
}

extension ChoosingViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ChoosingTransition()
    }
}
