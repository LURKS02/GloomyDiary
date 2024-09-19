//
//  CounselingViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import UIKit
import ComposableArchitecture

final class CounselingViewController: BaseViewController<CounselingView> {
    let store: StoreOf<Counseling>
    
    private let maxTextCount = 300
    
    init(store: StoreOf<Counseling>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - View Controller Life Cycle

extension CounselingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        bind()
        contentView.counselLetterView.letterCharacterCountLabel.text = "0/\(maxTextCount)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.contentView.counselLetterView.endEditing(true)
    }
}


// MARK: - bind

private extension CounselingViewController {
    func bind() {
        contentView.counselLetterView.letterTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        contentView.counselLetterView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.store.send(.startCounseling)
            })
            .disposed(by: disposeBag)
        
        contentView.letterSendingButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                
            })
            .disposed(by: disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.configure(with: store.character)
            
            self.contentView.counselLetterView.setState(store.counselState)
        }
    }
}


// MARK: - textView

extension CounselingViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = (textView.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        if updatedText.count <= maxTextCount {
            contentView.counselLetterView.letterCharacterCountLabel.text = "\(updatedText.count)/\(maxTextCount)"
            if updatedText.count == 0 {
                contentView.counselLetterView.configureForEmptyText()
                contentView.letterSendingButton.isEnabled = false
            } else if updatedText.count == maxTextCount {
                contentView.counselLetterView.configureForMaxText()
                contentView.letterSendingButton.isEnabled = true
            } else {
                contentView.counselLetterView.configureForSendableText()
                contentView.letterSendingButton.isEnabled = true
            }
            return true
        } else {
            return false
        }
    }
}


// MARK: - Keyboard

private extension CounselingViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            self.contentView.subviews.forEach {
                $0.transform = .identity.translatedBy(x: 0, y: -self.contentView.characterGreetingLabel.frame.height - 90)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.subviews.forEach {
                $0.transform = .identity
            }
        }
    }
}
