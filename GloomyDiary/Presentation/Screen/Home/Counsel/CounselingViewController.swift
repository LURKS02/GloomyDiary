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
    private let counselRepository: CounselRepositoryProtocol
    
    // MARK: - Properties
    
    private let maxTextCount = 300
    
    private lazy var animationClosure: () async throws -> String = { [weak self] in
        guard let self else { return "" }
        return try await self.counselRepository.counsel(to: self.store.character, with: self.contentView.counselLetterView.letterTextView.text)
    }
    
    
    // MARK: - Initialize

    init(store: StoreOf<Counseling>, counselRepository: CounselRepositoryProtocol) {
        self.store = store
        self.counselRepository = counselRepository
        super.init()
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
        
        self.navigationItem.hidesBackButton = true
        
        bind()
    }
    
    
    // MARK: - Touch Cycle

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
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
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let animations = self.contentView.subviews.map { Animation(view: $0,
                                                                   animationCase: .transform(transform: .identity.translatedBy(x: 0, y: -self.contentView.characterGreetingLabel.frame.height - 90)),
                                                                   duration: 0.3) }
        AnimationGroup(animations: animations,
                       mode: .parallel,
                       loop: .once(completion: nil))
        .run()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let animations = self.contentView.subviews.map { Animation(view: $0,
                                                                   animationCase: .transform(transform: .identity),
                                                                   duration: 0.3) }
        AnimationGroup(animations: animations,
                       mode: .parallel,
                       loop: .once(completion: nil))
        .run()
    }
}


// MARK: - Naivation

extension CounselingViewController {
    func navigateToResult(with character: CharacterDTO) {
        let store: StoreOf<CounselResult> = Store(initialState: .init(character: character), reducer: { CounselResult() })
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
