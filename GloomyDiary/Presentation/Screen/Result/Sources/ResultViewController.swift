//
//  ResultViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import CombineCocoa
import ComposableArchitecture
import UIKit

final class ResultViewController: BaseViewController<ResultView> {
    
    @UIBindable var store: StoreOf<CounselResult>
    
    var hasValidResult: Bool = false {
        didSet {
            configure(hasValidResult: hasValidResult)
        }
    }
    
    init(store: StoreOf<CounselResult>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ResultViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        self.navigationItem.hidesBackButton = true
    }
    
    func configure(hasValidResult: Bool) {
        if hasValidResult {
            configureValidResult()
        } else {
            configureErrorResult()
        }
    }
}


// MARK: - bind

private extension ResultViewController {
    func configureValidResult() {
        contentView.showValidResult()
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.contentView.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        contentView.validResultView.resultLetterView.copyButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapCopyButton))
                self?.copyToClipboard()
            }
            .store(in: &cancellables)
        
        contentView.validResultView.homeButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapHomeButton))
            }
            .store(in: &cancellables)
        
        contentView.validResultView.shareButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapShareButton))
            }
            .store(in: &cancellables)
        
        present(item: $store.scope(state: \.destination?.activity, action: \.scope.destination.activity)) { [weak self] _ in
            guard let self,
                  let session = self.store.session else { return UIViewController() }
            
            let textToShare = Sharing.makeBody(from: session)
            let itemsToShare: [Any] = [textToShare]
            let vc = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            return vc
        }
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.validResultView.configure(with: store.counselor)
            
            if let response = store.session?.response {
                self.contentView.validResultView.resultLetterView.letterTextView.text = response + "\n\n"
            }
        }
    }
    
    func configureErrorResult() {
        contentView.showErrorResult()
        
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.contentView.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        contentView.errorResultView.backButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapBackButton))
                
            }
            .store(in: &cancellables)
        
        contentView.errorResultView.homeButton.tapPublisher
            .sink { [weak self] in
                self?.store.send(.view(.didTapHomeButton))
            }
            .store(in: &cancellables)
        
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.errorResultView.configure(with: store.counselor)
        }
    }
}

private extension ResultViewController {
    func copyToClipboard() {
        let textToCopy = contentView.validResultView.resultLetterView.letterTextView.text
        UIPasteboard.general.string = textToCopy
        Toast.show(text: "클립보드에 복사되었습니다.")
    }
}


// MARK: - Transition

extension ResultViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        if store.session == nil {
            await contentView.playHidingErrorResult(duration: duration)
        } else {
            await contentView.playHidingValidResult(duration: duration)
        }
    }
}

extension ResultViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        if store.session == nil {
            await contentView.playShowingErrorResult(duration: duration)
        } else {
            await contentView.playShowingValidResult(duration: duration)
        }
    }
}

extension ResultViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.5,
            toDuration: 0.5,
            transitionContentType: .normalTransition
        )
    }
}
