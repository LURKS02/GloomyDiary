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
        super.init()
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
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                copyToClipboard()
            })
            .disposed(by: disposeBag)
        
        contentView.writingDiaryButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                didTapWritingDiaryButton()
            })
            .disposed(by: disposeBag)
        
        contentView.homeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                didTapHomeButton()
            })
            .disposed(by: disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            self.contentView.configure(with: store.character)
        }
    }
}

private extension ResultViewController {
    func copyToClipboard() {
        let textToCopy = contentView.resultLetterView.letterTextView.text
        UIPasteboard.general.string = textToCopy
        Toast.show(text: "클립보드에 복사되었습니다.")
    }
    
    func didTapWritingDiaryButton() {
        // TODO: - 다이어리 작성 기능
        Toast.show(text: "곧 추가될 기능이에요.")
    }
    
    func didTapHomeButton() {
        self.dismiss(animated: true)
    }
}
