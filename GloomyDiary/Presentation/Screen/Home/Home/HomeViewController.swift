//
//  HomeViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import ComposableArchitecture
import RxSwift
import RxRelay
import RxCocoa
import RxGesture

final class HomeViewController: BaseViewController<HomeView> {
    
    let store: StoreOf<Home>
    
    
    // MARK: - Properties
    
    private var loopAnimated: Bool = false
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<Home>) {
        self.store = store
        super.init(logID: "Home")
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
    }
}


// MARK: - bind

extension HomeViewController {
    private func bind() {
        contentView.gradientView.rx.tapGesture()
            .when(.recognized)
            .do(onNext: { _ in
                Logger.send(type: .tapped, "GradientView")
            })
            .subscribe(onNext: { [weak self] _ in
                self?.store.send(.ghostTapped)
            })
            .disposed(by: rx.disposeBag)
        
        contentView.startButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.startButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.navigateToCounseling()
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.ghostTalkingView.update(text: store.talkingType.description)
        }
    }
}


// MARK: - Navigation

extension HomeViewController {
    func navigateToCounseling() {
        let store: StoreOf<StartCounseling> = Store(initialState: .init(), reducer: { StartCounseling() })
        let startCounselingViewController = StartCounselingViewController(store: store)
        let navigationViewController = UINavigationController(rootViewController: startCounselingViewController)
        
        navigationViewController.modalPresentationStyle = .custom
        navigationViewController.transitioningDelegate = self
        
        self.present(navigationViewController, animated: true)
    }
}


// MARK: - Transition Animation

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        PresentingTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ResultDismissTransition()
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

extension HomeViewController: DismissedAppearable {
    func playAppearingAnimation() async {
        
        contentView.hideAllComponents()
        
        if let circularTabBarControllable = self.tabBarController as? CircularTabBarControllable {
            async let playAllComponentsFadeIn: () = contentView.playAllComponentsFadeIn()
            async let playTabBarFadeIn: () = circularTabBarControllable.showCircularTabBar(duration: 1.0)
            let _ = await (playAllComponentsFadeIn, playTabBarFadeIn)
        } else {
            await contentView.playAllComponentsFadeIn()
        }
    }
}

extension HomeViewController: PresentingDisappearable {
    func playDisappearingAnimation() async {
        if let circularTabBarControllable = self.tabBarController as? CircularTabBarControllable {
            async let playAllComponentsFadeOut: () = contentView.playFadeOutAllComponents()
            async let playTabBarFadeOut: () = circularTabBarControllable.hideCircularTabBar(duration: 1.0)
            let _ = await (playAllComponentsFadeOut, playTabBarFadeOut)
        } else {
            await contentView.playFadeOutAllComponents()
        }
    }
}
