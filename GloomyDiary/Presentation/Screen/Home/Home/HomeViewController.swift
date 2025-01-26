//
//  HomeViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import ComposableArchitecture
import RxSwift
import RxRelay
import RxCocoa
import RxGesture
import UIKit

final class HomeViewController: BaseViewController<HomeView> {
    
    @Dependency(\.logger) var logger
    
    let store: StoreOf<Home>
    
    
    // MARK: - Properties
    
    private var loopAnimated: Bool = false
    
    private var isFirstAppearance: Bool = true
    
    
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
        
        if !loopAnimated {
            defer { loopAnimated = true }
            contentView.ghostImageView.playBounce()
        }
        
        if !isFirstAppearance {
            store.send(.ghostTapped)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstAppearance {
            isFirstAppearance = false
        } else {
            store.send(.viewDidAppear)
        }
    }
}


// MARK: - bind

extension HomeViewController {
    private func bind() {
        contentView.gradientView.rx.tapGesture()
            .when(.recognized)
            .do(onNext: { [weak self] _ in
                self?.logger.send(.tapped, "GradientView", nil)
            })
            .subscribe(onNext: { [weak self] _ in
                self?.store.send(.ghostTapped)
            })
            .disposed(by: rx.disposeBag)
        
        contentView.startButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.startButton.title(for: .normal) else { return }
                self?.logger.send(.tapped, title, nil)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.navigateToCounseling()
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.ghostTalkingView.update(text: store.talkingType.description)
            
            if store.showReviewSuggestion {
                presentReviewSuggestion()
                store.send(.hideSuggestions)
            }
            
            if store.showNotificationSuggestion {
                presentNotificationSuggestion()
                store.send(.hideSuggestions)
            }
        }
    }
}


// MARK: - Navigation

extension HomeViewController {
    func presentReviewSuggestion() {
        let store: StoreOf<Review> = Store(initialState: .init(), reducer: { Review() })
        let reviewViewController = ReviewViewController(store: store)
        reviewViewController.modalPresentationStyle = .overFullScreen
        present(reviewViewController, animated: false)
    }
    
    func presentNotificationSuggestion() {
        let localNotificationViewController = LocalNotificationViewController()
        localNotificationViewController.modalPresentationStyle = .overFullScreen
        present(localNotificationViewController, animated: false)
    }
    
    func navigateToCounseling() {
        let store: StoreOf<StartCounseling> = Store(initialState: .init(), reducer: { StartCounseling() })
        let startCounselingViewController = StartCounselingViewController(store: store)
        startCounselingViewController.contentView.moonImageView.alpha = 1.0
        let navigationViewController = UINavigationController(rootViewController: startCounselingViewController)
        
        navigationViewController.modalPresentationStyle = .custom
        navigationViewController.transitioningDelegate = self
        
        self.present(navigationViewController, animated: true)
    }
}


// MARK: - Transition

extension HomeViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        contentView.moonImageView
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
        
        store.send(.ghostTapped)
        store.send(.viewDidAppear)
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

extension HomeViewController: ToTabSwitchable {
    func playTabAppearingAnimation() async {
        await contentView.playAppearingFromLeft()
    }
}

extension HomeViewController: FromTabSwitchable {
    func playTabDisappearingAnimation() async {
        await contentView.playDisappearingToRight()
    }
}
