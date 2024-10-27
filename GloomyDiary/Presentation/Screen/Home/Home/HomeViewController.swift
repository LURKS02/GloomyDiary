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
    }
}


// MARK: - bind

extension HomeViewController {
    private func bind() {
        contentView.gradientView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.store.send(.ghostTapped)
            })
            .disposed(by: rx.disposeBag)
        
        contentView.startButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let tabBarController = self.tabBarController as? CircularTabBarControllable else { return }
                
                Task {
                    async let contentViewAnimation: Void = self.contentView.playFadeOutAllComponents()
                    async let tabBarAnimation: Void = tabBarController.hideCircularTabBar(duration: 1.0)
                    _ = await (contentViewAnimation, tabBarAnimation)
                    
                    self.navigateToCharacterSelection()
                }
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
    func navigateToCharacterSelection() {
        let store: StoreOf<Choosing> = Store(initialState: .init(), reducer: { Choosing() })
        let choosingViewController = ChoosingViewController(store: store)
        let navigationViewController = UINavigationController(rootViewController: choosingViewController)
        
        self.definesPresentationContext = true
        navigationViewController.modalPresentationStyle = .overCurrentContext
        navigationViewController.transitioningDelegate = self
        
        self.present(navigationViewController, animated: false)
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ResultDismissTransition()
    }
}


// MARK: - Transition Animation

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
