//
//  StartCounselingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class StartCounselViewController: BaseViewController<StartCounselingView> {

    @UIBindable var store: StoreOf<StartCounsel>
    
    
    // MARK: - Properties
    
    private var isKeyboardShowing: Bool = false {
        didSet {
            updateContentOffset()
        }
    }
    
    private let backgroundTap = UITapGestureRecognizer()
    
    // MARK: - Initialize
    
    init(store: StoreOf<StartCounsel>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
        self.navigationController?.delegate = self
        store.send(.view(.viewDidLoad))
    }
}


// MARK: - bind

private extension StartCounselViewController {
    func bind() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        contentView.containerView.addGestureRecognizer(backgroundTap)
        
        backgroundTap.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.contentView.endEditing(true)
            }
            .store(in: &cancellables)
        
        contentView.titleTextField.textPublisher
            .sink { [weak self] text in
                guard let self, let text else { return }
                store.send(.view(.didEnterText(text)))
            }
            .store(in: &cancellables)
        
        contentView.nextButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                store.send(.view(.didTapNextButton))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.configure(isFirstProcess: store.isFirstProcess)
            self.contentView.nextButton.isEnabled = store.isSendable
            self.contentView.warningLabel.text = store.warning
        }
    }
}


// MARK: - Keyboard

private extension StartCounselViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShowing = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboardShowing = false
    }
    
    private func updateContentOffset() {
        if isKeyboardShowing {
            let translateY = -self.contentView.skyBadgeImageView.frame.maxY
             
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


// MARK: - Transition

extension StartCounselViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        await contentView.playFadeOutAllComponents(duration: duration)
    }
}

extension StartCounselViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        contentView.skyBadgeImageView
    }
    
    func completeTransition(duration: TimeInterval) async {
        contentView.skyBadgeImageView.transform = .identity.translatedBy(x: 0, y: .deviceAdjustedHeight(35))
        
        let percentages: [CGFloat] = [10, 70, 20]
        let calculatedDurations = percentages.map { duration * $0 / 100 }
        
        await contentView.playMovingSkyBadge(duration: calculatedDurations[0])
        await contentView.playFadeInFirstPart(duration: calculatedDurations[1])
        await contentView.playFadeInSecondPart(duration: calculatedDurations[2])
    }
}

extension StartCounselViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        return AnimatedTransition(
            fromDuration: 0.5,
            toDuration: 2.0,
            transitionContentType: .normalTransition
        )
    }
}
