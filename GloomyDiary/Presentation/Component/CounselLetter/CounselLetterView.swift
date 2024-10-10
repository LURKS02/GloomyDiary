//
//  CounselLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/6/24.
//

import UIKit
import RxRelay

final class CounselLetterView: BaseView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let letterImageViewTopPadding: CGFloat = 55
        static let letterWritingGuideLabelTopPadding: CGFloat = 14
        static let letterTextViewTopPadding: CGFloat = 34
        static let letterTextViewHorizontalPadding: CGFloat = 31
        static let letterTextViewBottomPadding: CGFloat = 10
        
        static let letterCharacterCountLabelTrailingPadding: CGFloat = 24
        static let letterCharacterCountLabelBottomPadding: CGFloat = 22
        
        static let uploadButtonTrailingPadding: CGFloat = 23
        static let uploadButtonBottomPadding: CGFloat = 20
    }
    
    
    // MARK: - Views
    
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
    
    let letterCharacterCountLabel: IntroduceLabel = IntroduceLabel()
    
    private var uploadButton: RoundedIconButton = RoundedIconButton(size: 51, iconName: "arrow.up.square")
    
    
    // MARK: - Properties

    var state: CounselState {
        willSet {
            switch newValue {
            case .notStarted:
                setupWithInitialState()
            case .inProgress:
                setupWithInProgressState()
            case .completed:
                setupWithCompletedState()
            }
        }
    }
    
    
    // MARK: - Initialize
    
    init(state: CounselState) {
        self.state = state
        
        super.init(frame: .zero)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle

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
            make.top.equalToSuperview().offset(Metric.letterImageViewTopPadding)
            make.centerX.equalToSuperview()
        }
        
        letterWritingGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(letterImageView.snp.bottom).offset(Metric.letterWritingGuideLabelTopPadding)
            make.centerX.equalToSuperview()
        }
        
        letterTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.letterTextViewTopPadding)
            make.leading.equalToSuperview().offset(Metric.letterTextViewHorizontalPadding)
            make.trailing.equalToSuperview().offset(-Metric.letterTextViewHorizontalPadding)
            make.bottom.equalTo(letterCharacterCountLabel.snp.top).offset(-Metric.letterTextViewBottomPadding)
        }
        
        letterCharacterCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Metric.letterCharacterCountLabelTrailingPadding)
            make.bottom.equalToSuperview().offset(-Metric.letterCharacterCountLabelBottomPadding)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Metric.uploadButtonTrailingPadding)
            make.bottom.equalToSuperview().offset(-Metric.uploadButtonBottomPadding)
        }
    }
}

private extension CounselLetterView {
    func setupWithInitialState() {
        letterTextView.isHidden = true
        letterCharacterCountLabel.isHidden = true
        uploadButton.isHidden = true
        
        letterImageView.isHidden = false
        letterWritingGuideLabel.isHidden = false
    }
    
    func setupWithInProgressState() {
        letterImageView.isHidden = true
        letterWritingGuideLabel.isHidden = true
        uploadButton.isHidden = true
        
        letterTextView.isHidden = false
        letterCharacterCountLabel.alpha = 0.3
        letterTextView.becomeFirstResponder()
    }
    
    func setupWithCompletedState() {
        letterCharacterCountLabel.isHidden = true
        letterWritingGuideLabel.isHidden = true
        letterImageView.isHidden = true
        
        uploadButton.isHidden = false
        letterTextView.text = "상담이 종료되었어요."
        letterTextView.isHidden = false
        letterTextView.isEditable = false
    }
}

extension CounselLetterView {
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
