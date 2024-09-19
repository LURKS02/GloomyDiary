//
//  CounselLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/6/24.
//

import UIKit
import RxRelay

final class CounselLetterView: BaseView {
    
    private let letterImageView: ImageView = ImageView().then {
        $0.setImage("letter")
        $0.setSize(56)
    }
    
    private let letterWritingGuideLabel: IntroduceLabel = IntroduceLabel().then {
        $0.text = "상담하고 싶은 내용을\n"
                + "편지로 적어볼까요?"
    }
    
    lazy var letterTextView: UITextView = UITextView().then {
        $0.font = .무궁화.title
        $0.textColor = .text(.highlight)
        $0.textAlignment = .left
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }
    
    lazy var letterCharacterCountLabel: IntroduceLabel = IntroduceLabel()
    
    private var uploadButton: RoundedIconButton = RoundedIconButton(size: 51, iconName: "arrow.up.square")
    
    override func setup() {
        backgroundColor = .component(.buttonPurple)
        applyCornerRadius(20)
    }
    
    override func addSubviews() {
        addSubview(letterImageView)
        addSubview(letterWritingGuideLabel)
        addSubview(letterTextView)
        addSubview(letterCharacterCountLabel)
        addSubview(uploadButton)
    }
    
    override func setupConstraints() {
        letterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.centerX.equalToSuperview()
        }
        
        letterWritingGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(letterImageView.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        
        letterTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(34)
            make.leading.equalToSuperview().offset(31)
            make.trailing.equalToSuperview().offset(-31)
            make.bottom.equalTo(letterCharacterCountLabel.snp.top).offset(-10)
        }
        
        letterCharacterCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-22)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-23)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}

extension CounselLetterView {
    func setState(_ state: CounselState) {
        switch state {
        case .notStarted:
            setupWithInitialState()
        case .inProgress:
            setupWithInProgressState()
            letterCharacterCountLabel.alpha = 0.3
            letterTextView.becomeFirstResponder()
        case .completed:
            setupWithCompletedState()
        }
    }
    
    func configureForEmptyText() {
        letterCharacterCountLabel.alpha = 0.3
    }
    
    func configureForSendableText() {
        letterCharacterCountLabel.alpha = 1.0
        letterCharacterCountLabel.textColor = .text(.highlight)
    }
    
    func configureForMaxText() {
        letterCharacterCountLabel.textColor = .text(.warning)
    }
}

private extension CounselLetterView {
    func setupWithInitialState() {
        letterImageView.alpha = 1.0
        letterWritingGuideLabel.alpha = 1.0
        letterTextView.alpha = 0.0
        letterCharacterCountLabel.alpha = 0.0
        uploadButton.alpha = 0.0
    }
    
    func setupWithInProgressState() {
        letterImageView.alpha = 0.0
        letterWritingGuideLabel.alpha = 0.0
        letterTextView.alpha = 1.0
        letterCharacterCountLabel.alpha = 1.0
        uploadButton.alpha = 0.0
    }
    
    func setupWithCompletedState() {
        letterImageView.alpha = 0.0
        letterWritingGuideLabel.alpha = 0.0
        letterTextView.alpha = 1.0
        letterCharacterCountLabel.alpha = 0.0
        uploadButton.alpha = 1.0
    }
}
