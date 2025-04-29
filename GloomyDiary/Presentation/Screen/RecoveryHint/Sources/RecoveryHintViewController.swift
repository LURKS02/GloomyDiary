//
//  RecoveryHintViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import ComposableArchitecture
import UIKit

final class RecoveryHintViewController: BaseViewController<RecoveryHintView> {
    
    let store: StoreOf<RecoveryHint>
    
    init(store: StoreOf<RecoveryHint>) {
        self.store = store
        
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        bind()
        
        navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        backButton.tintColor = AppColor.Component.navigationItem.color
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        store.send(.view(.didTapBackButton))
    }
    
    private func bind() {
        contentView.hintTextField.textPublisher
            .sink { [weak self] text in
                guard let self,
                      let text else { return }
                store.send(.view(.didEnterText(text)))
            }
            .store(in: &cancellables)
        
        contentView.nextButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapNextButton))
                Toast.show(text: "비밀번호를 설정했습니다.")
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            contentView.nextButton.isEnabled = store.isSendable
            contentView.warningLabel.text = store.warning
        }
    }
}

extension RecoveryHintViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        await contentView.playDisappearingAnimation(duration: duration)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension RecoveryHintViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 100,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        contentView.alpha = 0.0
        contentView.frame = targetFrame
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        await contentView.playAppearingAnimation(duration: duration)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension RecoveryHintViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.3,
            toDuration: 0.0,
            timing: .parallel,
            transitionContentType: .switchedHierarchyTransition
        )
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { context in
                if context.isCancelled {
                    Task { @MainActor in
                        guard let tabBarController = navigationController.tabBarController as? FloatingTabBarController else { return }
                        await tabBarController.playDisappearingTabBar(duration: 0.2)
                    }
                }
            }
        }
    }
}
