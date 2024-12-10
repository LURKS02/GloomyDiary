//
//  CounselingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import UIKit
import ComposableArchitecture

final class CounselingViewController: BaseViewController<CounselingView> {
    
    let store: StoreOf<Counseling>
    
    private var isKeyboardShowing: Bool = false {
        didSet {
            updateContentOffset()
        }
    }
    
    @Dependency(\.counselRepository) var counselRepository
    @Dependency(\.userSettingRepository) var userSettingRepository
    
    // MARK: - Properties
    
    private lazy var animationClosure: () async throws -> String = { [weak self] in
        guard let self,
              let weatherDTO = WeatherDTO(identifier: self.store.weatherIdentifier),
              let emojiDTO = EmojiDTO(identifier: self.store.emojiIdentifier) else {
            throw LocalError(message: "DTO Error")
        }
        
        let result = try await self.counselRepository.counsel(to: self.store.character,
                                           title: self.store.title,
                                           userInput: self.contentView.sendingLetterView.letterTextView.text,
                                           weather: weatherDTO,
                                                                     emoji: emojiDTO)
        userSettingRepository.update(keyPath: \.isFirstProcess, value: false)
        return result
    }
    
    
    // MARK: - Initialize

    init(store: StoreOf<Counseling>) {
        self.store = store
        super.init(logID: "Counseling")
        
        self.navigationItem.hidesBackButton = true
        contentView.tapGesture.addTarget(self, action: #selector(viewTouched))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    
    // MARK: - Touch Cycle
    
    @objc func viewTouched() {
        self.contentView.sendingLetterView.endEditing(true)
    }
}


// MARK: - bind

private extension CounselingViewController {
    private func bind() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        contentView.sendingLetterView.validationSubject
            .subscribe(onNext: { [weak self] validation in
                self?.contentView.letterSendingButton.isEnabled = validation
            })
            .disposed(by: rx.disposeBag)
        
        contentView.letterSendingButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.letterSendingButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                navigateToResult(with: store.character)
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.configure(with: store.character)
        }
    }
}


// MARK: - Keyboard

private extension CounselingViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShowing = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboardShowing = false
    }
    
    private func updateContentOffset() {
        if isKeyboardShowing {
            let translateY = -self.contentView.characterGreetingLabel.frame.height - 90
            UIView.animate(withDuration: 0.25) {
                self.contentView.containerView.transform = .identity.translatedBy(x: 0, y: translateY)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.contentView.containerView.transform = .identity
            }
        }
    }
}


// MARK: - Naivation

extension CounselingViewController {
    func navigateToResult(with character: CharacterDTO) {
        let store: StoreOf<CounselResult> = Store(initialState: .init(
            character: character,
            request: self.contentView.sendingLetterView.letterTextView.text
        ), reducer: { CounselResult() })
        let resultViewController = ResultViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(resultViewController,
                                                 animated: true)
    }
}

extension CounselingViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        CounselTransition(animationClosure: animationClosure)
    }
}
