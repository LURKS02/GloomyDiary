//
//  ChoosingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit
import ComposableArchitecture

final class ChoosingViewController: BaseViewController<ChoosingView> {
    let store: StoreOf<Choosing> = Store(initialState: Choosing.State()) {
        Choosing()
    }
    
    private let firstInitialize: Bool
    
    init(firstInitialize: Bool) {
        self.firstInitialize = firstInitialize
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentView.firstIntroduceLabel.alpha = 0.0
        contentView.secondIntroduceLabel.alpha = 0.0
        contentView.characterButtonStackView.alpha = 0.0
        contentView.characterIntroduceLabel.alpha = 0.0
        contentView.counselButton.alpha = 0.0
        contentView.characterButtonStackView.arrangedSubviews.forEach { view in
            guard let view = view as? CharacterButtonView else { return }
            view.button.isEnabled = false
        }
        
        AnimationManager.shared.run(animations: [
            .init(view: contentView.moonImageView, type: .moveUp(value: 35), duration: 1.5),
            .init(view: contentView.firstIntroduceLabel,
                                                       type: .fadeInOut(value: 1.0),
                                                       duration: 1.8),
                                                 .init(view:contentView.secondIntroduceLabel,
                                                       type: .fadeInOut(value: 1.0), duration: 2.0),
                                                 .init(view: contentView.characterButtonStackView,
                                                       type: .fadeInOut(value: 1.0),
                                                       duration: 1.5),
                                                 .init(view: contentView.characterIntroduceLabel,
                                                       type: .fadeInOut(value: 1.0),
                                                       duration: 1.8, 
                                                       completion: { [weak self] in
                                                           self?.contentView.characterButtonStackView.arrangedSubviews.forEach { view in
                                                               guard let view = view as? CharacterButtonView else { return }
                                                               view.button.isEnabled = true
                                                           }
                                                       })],
                                    mode: .once)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.send(.initialize(firstInitialize))
        
        contentView.characterButtonStackView.arrangedSubviews.forEach { view in
            guard let characterView = view as? CharacterButtonView else { return }
            
            characterView.button.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    self?.contentView.characterButtonStackView.arrangedSubviews.forEach { view in
                        guard let view = view as? CharacterButtonView else { return }
                        view.button.isSelected = false
                    }
                    
                    characterView.button.isSelected = true
                    
                    self?.contentView.counselButton.alpha = 1.0
                    
                    switch characterView.tag {
                    case 0:
                        self?.store.send(.characterTapped(character: .chan))
                    case 1:
                        self?.store.send(.characterTapped(character: .gomi))
                    case 2:
                        self?.store.send(.characterTapped(character: .beomji))
                    default:
                        return
                    }
                })
                .disposed(by: disposeBag)
        }
        
        contentView.counselButton.button.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.pushViewController(CounselingViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.firstIntroduceLabel.update(text: store.firstIntroduceText)
            
            self.contentView.secondIntroduceLabel.update(text: store.secondIntroduceText)
            
            self.contentView.characterIntroduceLabel.update(text: store.characterIntroduceText)
        }
    }
}
