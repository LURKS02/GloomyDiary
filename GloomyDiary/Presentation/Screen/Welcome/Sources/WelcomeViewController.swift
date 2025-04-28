//
//  WelcomeViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/20/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class WelcomeViewController: BaseViewController<WelcomeView> {
    @Dependency(\.logger) var logger
    
    let store: StoreOf<Welcome>
    
    // MARK: - Properties
    
    private let ghostTap = UITapGestureRecognizer()
    
    private let generator = UIImpactFeedbackGenerator(style: .light)

    
    // MARK: - Initialize

    init(store: StoreOf<Welcome>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        bind()
        contentView.hideAllComponents()
        self.navigationController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await contentView.playFadeInAllComponents()
            ghostTap.isEnabled = true
        }
        store.send(.view(.viewDidAppear))
    }
}


// MARK: - bind

private extension WelcomeViewController {
    func bind() {
        generator.prepare()
        contentView.ghostView.addGestureRecognizer(ghostTap)
        contentView.ghostView.isUserInteractionEnabled = true
        ghostTap.isEnabled = false
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.contentView.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        ghostTap.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                ghostTap.isEnabled = false
                store.send(.view(.didTapGhost))
                generator.impactOccurred()
            }
            .store(in: &cancellables)
    }
}


// MARK: - Transition

extension WelcomeViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        contentView.ghostView
    }
    
    func prepareTransition(duration: TimeInterval) async {
        contentView.stopGhostBouncing()
        await contentView.playFadeOutAllComponents(duration: duration)
    }
}

extension WelcomeViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            contentDuration: 1.0,
            toDuration: 0.5,
            timing: .withFrom,
            transitionContentType: .frameTransition
        )
    }
}
