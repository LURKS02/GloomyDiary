//
//  HomeViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import CombineCocoa
import ComposableArchitecture
import StoreKit
import UIKit

final class HomeViewController: BaseViewController<HomeView> {
    
    @UIBindable var store: StoreOf<Home>
    
    
    // MARK: - Properties
    
    private var isRunningLoopAnimation: Bool = false
    
    private let backgroundTap = UITapGestureRecognizer()
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<Home>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isRunningLoopAnimation {
            contentView.ghostImageView.playBounce()
            isRunningLoopAnimation = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        store.send(.view(.viewDidAppear))
    }
}


// MARK: - bind

extension HomeViewController {
    private func bind() {
        contentView.gradientView.addGestureRecognizer(backgroundTap)
        
        backgroundTap.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.store.send(.view(.didTapBackground))
            }
            .store(in: &cancellables)
        
        contentView.startButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.store.send(.view(.didTapStartButton))
            }
            .store(in: &cancellables)
        
        var transaction = UITransaction()
        transaction.uiKit.disablesAnimations = true
        
        present(item: $store.scope(state: \.destination?.review, action: \.scope.destination.review).transaction(transaction)) { store in
            let vc = ReviewViewController(store: store)
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
        
        present(item: $store.scope(state: \.destination?.notification, action: \.scope.destination.notification).transaction(transaction)) { store in
            let vc = LocalNotificationViewController(store: store)
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
        
        present(item: $store.scope(state: \.destination?.counseling, action: \.scope.destination.counseling)) { store in
            let navigationVC = CounselNavigationController(store: store)
            navigationVC.modalPresentationStyle = .fullScreen
            navigationVC.transitioningDelegate = self
            return navigationVC
        }
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.ghostTalkingView.update(text: store.talkingType.description)
            
            if store.isReviewSuggested {
                guard let windowScene = view.window?.windowScene else { return }
                AppStore.requestReview(in: windowScene)
            }
        }
    }
}


// MARK: - Transition

extension HomeViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        contentView.skyBadgeImageView
    }
    
    func prepareTransition(duration: TimeInterval) async {
        if let circularTabBarControllable = self.tabBarController as? CircularTabBarControllable {
            async let playAllComponentsFadeOut: () = contentView.playFadeOutAllComponents(duration: duration)
            async let playTabBarFadeOut: () = circularTabBarControllable.hideCircularTabBar(duration: duration)
            let _ = await (playAllComponentsFadeOut, playTabBarFadeOut)
        } else {
            await contentView.playFadeOutAllComponents(duration: duration)
        }
    }
}

extension HomeViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        contentView.hideAllComponents()
        
        if let circularTabBarControllable = self.tabBarController as? CircularTabBarControllable {
            async let playAllComponentsFadeIn: () = contentView.playAllComponentsFadeIn(duration: duration)
            async let playTabBarFadeIn: () = circularTabBarControllable.showCircularTabBar(duration: duration)
            let _ = await (playAllComponentsFadeIn, playTabBarFadeIn)
        } else {
            await contentView.playAllComponentsFadeIn(duration: duration)
        }
        
        store.send(.view(.didTapBackground))
        store.send(.view(.viewDidAppear))
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            toDuration: 4.5,
            transitionContentType: .normalTransition)
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            toDuration: 0.5,
            transitionContentType: .normalTransition
        )
    }
}

extension HomeViewController: ToTabSwitchAnimatable {
    func playTabAppearingAnimation() async {
        await contentView.playAppearingFromLeft()
    }
}

extension HomeViewController: FromTabSwitchAnimatable {
    func playTabDisappearingAnimation() async {
        await contentView.playDisappearingToRight()
    }
}
