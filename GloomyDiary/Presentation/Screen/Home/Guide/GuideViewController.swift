//
//  GuideViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/21/24.
//

import UIKit
import ComposableArchitecture

final class GuideViewController: BaseViewController<GuideView> {
    
    private var animationCount: Int = 1
    
    private var isRunningTask = false
    
    init() {
        super.init(logID: "Guide")
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}


// MARK: - bind

private extension GuideViewController {
    func bind() {
        contentView.rx.tapGesture()
            .when(.recognized)
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                Logger.send(type: .tapped, "튜토리얼 클릭", parameters: ["횟수": animationCount])
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                guard animationCount < contentView.labels.count else { return navigateToStartCounsel() }
                
                if self.isRunningTask { return }
                self.isRunningTask = true
                
                Task { @MainActor in
                    await self.contentView.runLabelAnimation(index: self.animationCount)
                    self.animationCount += 1
                    self.isRunningTask = false
                    self.contentView.isUserInteractionEnabled = true
                }
                
            })
            .disposed(by: rx.disposeBag)
    }
}


// MARK: - Navigation

extension GuideViewController {
    func navigateToStartCounsel() {
        let store: StoreOf<StartCounseling> = Store(initialState: .init(), reducer: { StartCounseling() })
        let startCounselingViewController = StartCounselingViewController(store: store)
        navigationController?.delegate = self
        navigationController?.pushViewController(startCounselingViewController, animated: true)
    }
}


// MARK: - Transition Animation

extension GuideViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        GuideOverTransition()
    }
}
