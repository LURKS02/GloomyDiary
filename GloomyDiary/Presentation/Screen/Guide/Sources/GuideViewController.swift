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
    
    let store: StoreOf<Guide>
    
    // MARK: - Properties
    
    private let backgroundTap = UITapGestureRecognizer()
    
    private var animatedCount = 0
    
    private var animationLimit: Int {
        contentView.labels.count
    }
    
    
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
        contentView.gradientView.addGestureRecognizer(backgroundTap)
        
        backgroundTap.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.store.send(.view(.didTapBackground))
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self,
                  animatedCount != store.animationCount else { return }
            
            animatedCount = store.animationCount
            
            Task {
                self.backgroundTap.isEnabled = false
                await self.contentView.runLabelAnimation(index: self.store.animationCount)
                self.backgroundTap.isEnabled = true
            }
        }
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
