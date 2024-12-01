//
//  StartCounselingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import UIKit
import ComposableArchitecture

final class StartCounselingViewController: BaseViewController<StartCounselingView> {
    
    let store: StoreOf<StartCounseling>
    
    // MARK: - Initialize
    
    init(store: StoreOf<StartCounseling>) {
        self.store = store
        let isFirstProcess = store.isFirstProcess
        let contentView = StartCounselingView(isFirstProcess: isFirstProcess)
        super.init(contentView, logID: "StartCounseling")
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.contentView.titleTextField.endEditing(true)
    }
}


// MARK: - bind

private extension StartCounselingViewController {
    func bind() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        contentView.titleTextField.textControlProperty
            .subscribe(onNext: { [weak self] text in
                guard let self,
                      let text else { return }
                self.store.send(.input(title: text))
            })
            .disposed(by: rx.disposeBag)
        
        contentView.nextButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.nextButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let value = contentView.titleTextField.text else { return }
                navigateToWeatherSelection(with: value)
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.nextButton.isEnabled = store.isSendable
            self.contentView.warningLabel.text = store.warning
        }
    }
}


// MARK: - Keyboard

private extension StartCounselingViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        let translateY = -self.contentView.moonImageView.frame.maxY
        let animation = Animation(view: self.contentView,
                                  animationCase: .transform(transform: .identity.translatedBy(x: 0, y: translateY)),
                                  duration: 0.3)
        
        AnimationGroup(animations: [animation],
                       mode: .parallel,
                       loop: .once(completion: nil))
        .run()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let animation = Animation(view: self.contentView,
                                  animationCase: .transform(transform: .identity),
                                  duration: 0.3)
        
        AnimationGroup(animations: [animation],
                       mode: .parallel,
                       loop: .once(completion: nil))
        .run()
    }
}

// MARK: - Navigation

extension StartCounselingViewController {
    func navigateToWeatherSelection(with title: String) {
        let store: StoreOf<ChoosingWeather> = Store(initialState: .init(title: title), reducer: { ChoosingWeather() })
        let choosingWeatherViewController = ChoosingWeatherViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(choosingWeatherViewController, animated: true)
    }
}


// MARK: - Transition Animation

extension StartCounselingViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        PresentingTransition()
    }
}

extension StartCounselingViewController: Presentable {
    func playAppearingAnimation() async {
        contentView.hideAllComponents()
        await contentView.playFadeInFirstPart()
        await contentView.playFadeInSecondPart()
    }
}

extension StartCounselingViewController: PresentingDisappearable {
    func playDisappearingAnimation() async {
        await contentView.playFadeOutAllComponents()
    }
}
