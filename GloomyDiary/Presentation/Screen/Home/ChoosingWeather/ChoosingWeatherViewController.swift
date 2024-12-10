//
//  ChoosingWeatherViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit
import ComposableArchitecture

final class ChoosingWeatherViewController: BaseViewController<ChoosingWeatherView> {
    
    let store: StoreOf<ChoosingWeather>
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<ChoosingWeather>) {
        self.store = store
        super.init(logID: "ChoosingWeather")
        
        self.navigationItem.hidesBackButton = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
}


// MARK: - bind

extension ChoosingWeatherViewController {
    private func bind() {
        contentView.allWeatherButtons.forEach { button in
            button.rx.tap
                .do(onNext: { _ in
                    let identifier = button.identifier
                    Logger.send(type: .tapped, "날씨 버튼", parameters: ["날씨": identifier])
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
                Logger.send(type: .tapped, title, parameters: ["선택한 날씨": selectedWeather])
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
        let store: StoreOf<ChoosingEmoji> = Store(initialState: .init(title: store.title, weatherIdenfitier: weatherIdentifier), reducer: { ChoosingEmoji() })
        let choosingEmojiViewController = ChoosingEmojiViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(choosingEmojiViewController, animated: true)
    }
}


// MARK: - Transition Animation

extension ChoosingWeatherViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        PresentingTransition()
    }
}

extension ChoosingWeatherViewController: Presentable {
    func playAppearingAnimation() async {
        contentView.hideAllComponents()
        await contentView.playFadeInAllComponents()
    }
}

extension ChoosingWeatherViewController: PresentingDisappearable {
    func playDisappearingAnimation() async {
        await contentView.playFadeOutAllComponents()
    }
}
