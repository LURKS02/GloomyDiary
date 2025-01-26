//
//  CounselLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/6/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SendingLetterView: LetterView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let letterImageViewTopPadding: CGFloat = .deviceAdjustedHeight(55)
        static let letterImageSize: CGFloat = .deviceAdjustedHeight(56)
        static let letterWritingGuideLabelTopPadding: CGFloat = 14
        
        static let letterCharacterCountLabelTrailingPadding: CGFloat = 24
        static let letterCharacterCountLabelBottomPadding: CGFloat = 10
    }
    
    
    // MARK: - Views
    
    private let letterImageView = UIImageView().then {
        $0.image = UIImage(named: "letter")
    }
    
    private let letterWritingGuideLabel = NormalLabel().then {
        $0.text = """
        오늘 하루 있었던 일들을
        편지로 적어볼까요?
        """
    }
    
    private lazy var letterCharacterCountLabel = UILabel().then {
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .center
        $0.text = "0/\(maxTextCount)"
    }
    
    
    // MARK: - Properties
    
    private let maxTextCount = 300
    
    let validationSubject = BehaviorSubject<Bool>(value: false)

    
    // MARK: - View Life Cycle

    override func setup() {
        super.setup()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        
        letterTextView.isHidden = true
        letterCharacterCountLabel.isHidden = true
        letterImageView.isHidden = false
        letterWritingGuideLabel.isHidden = false
        letterTextView.delegate = self
        
        backgroundColor = .component(.buttonPurple)
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(letterImageView)
        addSubview(letterWritingGuideLabel)
        addSubview(letterCharacterCountLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        letterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.letterImageViewTopPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(Metric.letterImageSize)
            make.width.equalTo(Metric.letterImageSize)
        }
        
        letterWritingGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(letterImageView.snp.bottom).offset(Metric.letterWritingGuideLabelTopPadding)
            make.centerX.equalToSuperview()
        }
        
        letterCharacterCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Metric.letterCharacterCountLabelTrailingPadding)
            make.bottom.equalToSuperview().offset(-Metric.letterCharacterCountLabelBottomPadding)
        }
    }
}

private extension SendingLetterView {
    @objc private func handleTap() {
        letterImageView.isHidden = true
        letterWritingGuideLabel.isHidden = true
        
        letterTextView.isHidden = false
        letterCharacterCountLabel.isHidden = false
        letterCharacterCountLabel.alpha = 0.3
        letterCharacterCountLabel.textColor = .text(.highlight)
        letterTextView.becomeFirstResponder()
    }
}

extension SendingLetterView {
    func configureForEmptyText() {
        letterCharacterCountLabel.alpha = 0.3
        letterCharacterCountLabel.textColor = .text(.highlight)
    }
    
    func configureForSendableText() {
        letterCharacterCountLabel.alpha = 0.7
        letterCharacterCountLabel.textColor = .text(.highlight)
    }
    
    func configureForMaxText() {
        letterCharacterCountLabel.textColor = .text(.warning)
    }
}

// MARK: - textView

extension SendingLetterView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = (textView.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        if updatedText.count <= maxTextCount {
            letterCharacterCountLabel.text = "\(updatedText.count)/\(maxTextCount)"
            if updatedText.count == 0 {
                configureForEmptyText()
                validationSubject.onNext(false)
            } else if updatedText.count == maxTextCount {
                configureForMaxText()
                validationSubject.onNext(true)
            } else {
                configureForSendableText()
                validationSubject.onNext(true)
            }
            return true
        } else {
            return false
        }
    }
}
