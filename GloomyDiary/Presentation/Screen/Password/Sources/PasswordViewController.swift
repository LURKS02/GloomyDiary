//
//  PasswordViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import ComposableArchitecture
import UIKit

final class PasswordViewController: BaseViewController<PasswordView> {
    
    let store: StoreOf<Password>
    
    init(store: StoreOf<Password>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        navigationController?.delegate = self
        
        Task { @MainActor in
            guard let tabBarController = tabBarController as? FloatingTabBarController else { return }
            await tabBarController.playDisappearingTabBar(duration: 0.3)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
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
}

extension PasswordViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        await contentView.playDisappearingAnimation(duration: duration)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension PasswordViewController: ToTransitionable {
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

extension PasswordViewController: UINavigationControllerDelegate {
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
