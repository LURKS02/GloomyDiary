//
//  PasswordSettingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import ComposableArchitecture
import UIKit

final class PasswordSettingViewController: BaseViewController<PasswordView> {
    
    let store: StoreOf<Password>
    
    private let backgroundTap = UITapGestureRecognizer()
    
    init(store: StoreOf<Password>) {
        self.store = store
        let contentView = PasswordView(totalPins: store.totalPins)
        
        super.init(contentView)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        bind()
        
        navigationController?.delegate = self
        
        Task { @MainActor in
            guard let tabBarController = tabBarController as? FloatingTabBarController else { return }
            await tabBarController.playDisappearingTabBar(duration: 0.3)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        contentView.makeTextFieldFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
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
        contentView.addGestureRecognizer(backgroundTap)
        
        backgroundTap.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                contentView.makeTextFieldFirstResponder()
            }
            .store(in: &cancellables)
        
        contentView.hiddenTextField.textPublisher
            .sink { [weak self] input in
                guard let input,
                      let self,
                      input.count <= store.totalPins else { return }
                
                store.send(.view(.didEnterPassword(input)))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            switch store.checkFlag {
            case .initial:
                contentView.highlightStarlights(number: store.initialPassword.count)
            case .resetForConfirmation:
                contentView.configureForConfirmation()
            case .mismatch:
                contentView.configureForMismatch()
            case .confirming:
                contentView.highlightStarlights(number: store.confirmingPassword.count)
            case .confirmed:
                navigationController?.delegate = nil
            }
        }
    }
}

extension PasswordSettingViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        await contentView.playDisappearingAnimation(duration: duration)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension PasswordSettingViewController: ToTransitionable {
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

extension PasswordSettingViewController: UINavigationControllerDelegate {
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
