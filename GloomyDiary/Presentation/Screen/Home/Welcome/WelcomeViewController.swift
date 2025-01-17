//
//  WelcomeViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/20/24.
//

import UIKit
import ComposableArchitecture

final class WelcomeViewController: BaseViewController<WelcomeView> {
    init() {
        super.init(logID: "Welcome")
    }
    
    @Dependency(\.logger) var logger
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WelcomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    
        bind()
        contentView.hideAllComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await contentView.playFadeInAllComponents()
        }
    }
}


// MARK: - bind

private extension WelcomeViewController {
    func bind() {
        contentView.ghostImageView.rx.tapGesture()
            .when(.recognized)
            .do(onNext: { [weak self] _ in
                self?.logger.send(.tapped, "유령 버튼", nil)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                navigateToGuide()
            })
            .disposed(by: rx.disposeBag)
    }
}


// MARK: - Navigation

extension WelcomeViewController {
    func navigateToGuide() {
        let guideViewController = GuideViewController()
        navigationController?.delegate = self
        navigationController?.pushViewController(guideViewController, animated: true)
    }
}


// MARK: - TransitionAnimation

extension WelcomeViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        WelcomeTransition()
    }
}
