//
//  CounselLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/6/24.
//

import UIKit

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
    
    let letterCharacterCountLabel = UILabel().then {
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .center
    }

    
    // MARK: - View Life Cycle

    override func setup() {
        super.setup()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        
        letterTextView.isHidden = true
        letterCharacterCountLabel.isHidden = true
        letterImageView.isHidden = false
        letterWritingGuideLabel.isHidden = false
        
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
    func updateConfiguration(state: SendingTextState) {
        switch state {
        case .empty:
            letterCharacterCountLabel.alpha = 0.3
            letterCharacterCountLabel.textColor = .text(.highlight)
        case .max:
            letterCharacterCountLabel.textColor = .text(.warning)
        case .sendable:
            letterCharacterCountLabel.alpha = 0.7
            letterCharacterCountLabel.textColor = .text(.highlight)
        }
    }
}
