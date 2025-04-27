//
//  ChoosingWeatherViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class ChoosingWeatherViewController: BaseViewController<ChoosingWeatherView> {
    
    let store: StoreOf<ChoosingWeather>
    
    // MARK: - Initialize
    
    init(store: StoreOf<ChoosingWeather>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        contentView.hideAllComponents()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.delegate = self
    }
}


// MARK: - bind

extension ChoosingWeatherViewController {
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
        
        contentView.allWeatherButtons.forEach { button in
            button.tapPublisher
                .sink { [weak self] in
                    guard let self else { return }
                    store.send(.view(.didTapWeatherButton(identifier: button.identifier)))
                }
                .store(in: &cancellables)
        }
        
        contentView.allWeatherButtons.forEach { button in
            button.controlEventPublisher(for: .touchUpOutside)
                .sink { [weak self] in
                    guard let self else { return }
                    contentView.spotlight(to: store.weather?.identifier)
                }
                .store(in: &cancellables)
        }
        
        contentView.nextButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                store.send(.view(.didTapNextButton))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.spotlight(to: store.weather?.identifier)
            self.contentView.nextButton.isEnabled = (store.weather != nil)
        }
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
