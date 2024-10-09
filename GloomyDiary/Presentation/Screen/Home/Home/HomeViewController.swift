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
        
        Task {
            await contentView.ghostImageView.playFadeIn()
        }
        
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
            .disposed(by: disposeBag)
        
        contentView.startButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                Task {
                    async let contentViewAnimation: Void = self.contentView.playFadeOutAllComponents()
                    async let tabBarAnimation: Void = self.playFadeOutTabBar()
                    
                    _ = await (contentViewAnimation, tabBarAnimation)
                    
                    self.navigateToCharacterSelection()
                }
            })
            .disposed(by: disposeBag)
        
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
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: false)
    }
}


// MARK: - Animations

extension HomeViewController {
    @MainActor
    func playFadeOutTabBar() async {
        guard let tabBarController = self.tabBarController else { return }
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: tabBarController.tabBar,
                                              animationCase: .fadeOut,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
