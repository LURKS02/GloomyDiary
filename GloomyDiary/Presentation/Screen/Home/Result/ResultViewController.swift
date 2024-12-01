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
        
        bind()
        
    }
}


// MARK: - bind

private extension ResultViewController {
    func bind() {
        contentView.resultLetterView.copyButton.rx.tap
            .do(onNext: { _ in
                Logger.send(type: .tapped, "클립보드 복사 버튼")
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                copyToClipboard()
            })
            .disposed(by: rx.disposeBag)
        
        contentView.homeButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.homeButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                didTapHomeButton()
            })
            .disposed(by: rx.disposeBag)
        
        contentView.shareButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let title = self?.contentView.shareButton.title(for: .normal) else { return }
                Logger.send(type: .tapped, title)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                didTapShareButton()
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.configure(with: store.character)
            
            self.contentView.resultLetterView.letterTextView.text = store.response + "\n\n"
        }
    }
}

private extension ResultViewController {
    func copyToClipboard() {
        let textToCopy = contentView.resultLetterView.letterTextView.text
        UIPasteboard.general.string = textToCopy
        Toast.show(text: "클립보드에 복사되었습니다.")
    }
    
    func didTapHomeButton() {
        self.dismiss(animated: true)
    }
    
    func didTapShareButton() {
        let textToShare = "✉️ \(store.character.name)로부터 답장이 도착했어요!\n\n보낸 내용: \(store.request)\n\n답장: [\(store.response)]\n\n\(store.character.name)와 더 많은 이야기를 나누고 싶다면 아래 링크를 방문해보세요! 🥳\n\nhttps://www.apple.com"
        
        let itemsToShare: [Any] = [textToShare]
        
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        present(activityViewController, animated: true)
    }
}


// MARK: - Transition Animation

extension ResultViewController: Dismissable {
    func playDismissingAnimation() async {
        await contentView.playAllComponentsFadeOut()
    }
}
