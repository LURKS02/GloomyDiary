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
    private var loopAnimated: Bool = false
    
    let store: StoreOf<Home>
    
    init(store: StoreOf<Home>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !loopAnimated {
            defer { loopAnimated = true }
            contentView.ghostImageView.startLoopMoving()
        }
        
        AnimationManager.shared.run(animations: [.init(view: self.contentView.ghostImageView, type: .fadeInOut(value: 1.0), duration: 1.0, curve: .easeIn)], mode: .once)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.gradientView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.store.send(.ghostTapped)
            })
            .disposed(by: disposeBag)
        
        contentView.startButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                AnimationManager.shared.run(animations: [.init(view: self?.contentView.talkingView,
                                                               type: .fadeInOut(value: 0.0),
                                                               duration: 1.0)],
                                            mode: .once)
                AnimationManager.shared.run(animations: [.init(view: self?.contentView.sparklingLottieView,
                                                               type: .fadeInOut(value: 0.0),
                                                               duration: 1.0)],
                                            mode: .once)
                AnimationManager.shared.run(animations: [.init(view: self?.contentView.startButton,
                                                               type: .fadeInOut(value: 0.0),
                                                               duration: 1.0)],
                                            mode: .once)
                AnimationManager.shared.run(animations: [.init(view: self?.contentView.ghostImageView,
                                                               type: .fadeInOut(value: 0.0),
                                                               duration: 1.0)],
                                            mode: .once)
                AnimationManager.shared.run(animations: [.init(view: self?.contentView.pulsingCircleLottieView,
                                                               type: .fadeInOut(value: 0.0),
                                                               duration: 1.0)],
                                            mode: .once)
                AnimationManager.shared.run(animations: [.init(view: self?.tabBarController?.tabBar,
                                                               type: .fadeInOut(value: 0.0),
                                                               duration: 1.0,
                                                               completion: {
                    let store: StoreOf<Choosing> = Store(initialState: .init(), reducer: { Choosing() })
                    let choosingViewController = ChoosingViewController(store: store)
                    let navigationViewController = UINavigationController(rootViewController: choosingViewController)
                    navigationViewController.modalPresentationStyle = .fullScreen
                    self?.present(navigationViewController, animated: false)})],
                                            mode: .once)
            })
            .disposed(by: disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.talkingView.update(text: store.talkingType.description)
        }
    }
}
