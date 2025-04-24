//
//  SettingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import ComposableArchitecture
import UIKit

final class SettingViewController: BaseViewController<SettingView> {
    var store: StoreOf<Setting>
    
    init(store: StoreOf<Setting>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        navigationController?.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { @MainActor in
            guard let tabBarController = tabBarController as? FloatingTabBarController else { return }
            await tabBarController.playAppearingTabBar(duration: 0.2)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
    }
}

extension SettingViewController {
    private func bind() {
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.contentView.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefreshWithoutAnimation)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.contentView.changeThemeIfNeeded()
            }
            .store(in: &cancellables)

        
        contentView.menuPublisher
            .sink { [weak self] settingCase in
                self?.store.send(.view(.didTapMenuButton(settingCase)))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.configure(with: store.state.settingItems)
            self.contentView.changeThemeIfNeeded()
        }
    }
}


// MARK: - Transition

extension SettingViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        return
    }
}

extension SettingViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        return
    }
}

extension SettingViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.0,
            toDuration: 0.3,
            transitionContentType: .normalTransition
        )
    }
}

extension SettingViewController: ToTabSwitchAnimatable {
    func playTabAppearingAnimation(direction: TabBarDirection) async {
        await contentView.playAppearing(direction: direction)
    }
}

extension SettingViewController: FromTabSwitchAnimatable {
    func playTabDisappearingAnimation(direction: TabBarDirection) async {
        await contentView.playDisappearing(direction: direction)
    }
}
