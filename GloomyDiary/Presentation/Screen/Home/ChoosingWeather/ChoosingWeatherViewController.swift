//
//  ChoosingWeatherViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import ComposableArchitecture
import Dependencies
import UIKit

final class ChoosingWeatherViewController: BaseViewController<ChoosingWeatherView> {
    
    let store: StoreOf<ChoosingWeather>
    
    @Dependency(\.logger) var logger
    
    // MARK: - Initialize
    
    init(store: StoreOf<ChoosingWeather>) {
        self.store = store
        super.init()
        
        self.navigationItem.hidesBackButton = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        contentView.hideAllComponents()
    }
}


// MARK: - bind

extension ChoosingWeatherViewController {
    private func bind() {
        contentView.allWeatherButtons.forEach { button in
            button.rx.tap
                .do(onNext: { [weak self] _ in
                    let identifier = button.identifier
                    self?.logger.send(
                        .tapped,
                        "날씨 버튼",
                        ["날씨": identifier]
                    )
                })
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    store.send(.weatherTapped(identifier: button.identifier))
                })
                .disposed(by: rx.disposeBag)
        }
        
        contentView.allWeatherButtons.forEach { button in
            button.rx.controlEvent(.touchUpOutside)
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    contentView.spotlight(to: store.weatherIdentifier)
                })
                .disposed(by: rx.disposeBag)
        }
        
        contentView.nextButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.nextButton.title(for: .normal),
                      let selectedWeather = self?.store.weatherIdentifier else { return }
                self?.logger.send(
                    .tapped,
                    title,
                    ["선택한 날씨": selectedWeather]
                )
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let weatherIdentifier = store.weatherIdentifier else { return }
                navigateToEmojiSelection(with: weatherIdentifier)
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.spotlight(to: store.weatherIdentifier)
            self.contentView.nextButton.isEnabled = store.isSendable
        }
    }
}


// MARK: - Navigation

extension ChoosingWeatherViewController {
    func navigateToEmojiSelection(with weatherIdentifier: String) {
        let store: StoreOf<ChoosingEmoji> = Store(
            initialState: .init(title: store.title, weatherIdenfitier: weatherIdentifier),
            reducer: { ChoosingEmoji()}
        )
        let choosingEmojiViewController = ChoosingEmojiViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(choosingEmojiViewController, animated: true)
    }
}


// MARK: - Transition

extension ChoosingWeatherViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        await contentView.playFadeOutAllComponents(duration: duration)
    }
}

extension ChoosingWeatherViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        await contentView.playFadeInAllComponents(duration: duration)
    }
}

extension ChoosingWeatherViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            toDuration: 2.0,
            transitionContentType: .normalTransition
        )
    }
}
