//
//  GuideViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/21/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class GuideViewController: BaseViewController<GuideView> {
    @Dependency(\.logger) var logger
    
    let store: StoreOf<Guide>
    
    // MARK: - Properties
    
    private var animationCount: Int = 1
    private var isRunningTask = false
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<Guide>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.delegate = self
    }
}


// MARK: - bind

private extension GuideViewController {
    func bind() {
        contentView.rx.tapGesture()
            .when(.recognized)
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.logger.send(
                    .tapped,
                    "튜토리얼 클릭",
                    ["횟수": animationCount]
                )
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                guard animationCount < contentView.labels.count else {
                    store.send(.delegate(.navigateToStartCounsel))
                    return
                }
                
                if self.isRunningTask { return }
                self.isRunningTask = true
                self.contentView.isUserInteractionEnabled = false
                
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


// MARK: - Transition

extension GuideViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        await contentView.hideAllComponents(duration: duration)
    }
}

extension GuideViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        contentView.ghostView
    }
    
    func completeTransition(duration: TimeInterval) async {
        await contentView.runLabelAnimation(index: 0)
    }
}

extension GuideViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            toDuration: 4.5,
            transitionContentType: .normalTransition
        )
    }
}
