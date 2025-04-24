//
//  ThemeViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/21/25.
//

import ComposableArchitecture
import UIKit

final class ThemeViewController: BaseViewController<ThemeView> {
    let store: StoreOf<ChoosingTheme>
    
    private var previousFrame: CGRect = .zero
    
    init(store: StoreOf<ChoosingTheme>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if contentView.scrollView.frame != previousFrame {
            previousFrame = contentView.scrollView.frame
            contentView.switchToPage(store.page, animated: false)
        }
    }
}

extension ThemeViewController {
    private func bind() {
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self,
                      store.theme == .default else { return }
                
                UIView.animate(withDuration: 0.2) {
                    self.contentView.changeThemeIfNeeded(with: self.store.theme)
                }
            }
            .store(in: &cancellables)
        
        contentView.allModeButtons.forEach { button in
            button.tapPublisher
                .sink { [weak self] in
                    guard let self else { return }
                    store.send(.view(.didTapMode(button.identifier)))
                }
                .store(in: &cancellables)
        }
        
        contentView.selectButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                store.send(.view(.didTapSelectButton))
            }
            .store(in: &cancellables)
        
        contentView.pageSubject
            .sink { [weak self] page in
                guard let self else { return }
                store.send(.view(.didScrollToPage(page)))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.switchToPage(store.page, animated: true)
            self.contentView.nameLabel.text = store.theme.name
            self.contentView.informationLabel.text = store.theme.description
            
            self.changeThemeIfNeeded(with: store.theme)
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
    
    func changeThemeIfNeeded(with theme: AppearanceMode) {
        UIView.animate(withDuration: 0.15) {
            self.navigationItem.leftBarButtonItem?.tintColor = AppColor.Component.navigationItem.color(for: theme)
            self.contentView.changeThemeIfNeeded(with: theme)
        }
    }
}

extension ThemeViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        await contentView.playDisappearingAnimation(duration: duration)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension ThemeViewController: ToTransitionable {
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

extension ThemeViewController: UINavigationControllerDelegate {
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
