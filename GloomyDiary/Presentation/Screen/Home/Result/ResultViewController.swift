//
//  ResultViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import UIKit
import ComposableArchitecture

final class ResultViewController: BaseViewController<ResultView> {
    let store: StoreOf<CounselResult>
    
    var hasValidResult: Bool = false {
        didSet {
            configure(hasValidResult: hasValidResult)
        }
    }
    
    init(store: StoreOf<CounselResult>) {
        self.store = store
        super.init(logID: "Result")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ResultViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        contentView.validResultView.resultLetterView.copyButton.rx.tap
            .do(onNext: { _ in
                Logger.send(type: .tapped, "클립보드 복사 버튼")
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                copyToClipboard()
            })
            .disposed(by: rx.disposeBag)
        
        contentView.validResultView.homeButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.validResultView.homeButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                didTapHomeButton()
            })
            .disposed(by: rx.disposeBag)
        
        contentView.validResultView.shareButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.validResultView.shareButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                didTapShareButton()
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.validResultView.configure(with: store.character)
            
            self.contentView.validResultView.resultLetterView.letterTextView.text = store.response + "\n\n"
        }
    }
    
    func configureErrorResult() {
        contentView.showErrorResult()
        
        contentView.errorResultView.backButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.errorResultView.backButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                navigationController?.delegate = self
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        contentView.errorResultView.homeButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.errorResultView.homeButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                didTapHomeButton()
            })
            .disposed(by: rx.disposeBag)
        
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.errorResultView.configure(with: store.character)
        }
    }
}

private extension ResultViewController {
    func copyToClipboard() {
        let textToCopy = contentView.validResultView.resultLetterView.letterTextView.text
        UIPasteboard.general.string = textToCopy
        Toast.show(text: "클립보드에 복사되었습니다.")
    }
    
    func didTapHomeButton() {
        self.dismiss(animated: true)
    }
    
    func didTapShareButton() {
        ShareService.share(character: store.character,
                           request: store.request,
                           response: store.response,
                           in: self)
    }
}


// MARK: - Transition Animation

extension ResultViewController: Dismissable {
    func playDismissingAnimation() async {
        if hasValidResult {
            await contentView.validResultView.playAllComponentsFadeOut()
        } else {
            await contentView.errorResultView.playAllComponentsFadeOut()
        }
    }
}

extension ResultViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ResultBackTransition()
    }
}
