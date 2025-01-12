//
//  ResponseHistoryLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class ResponseHistoryLetterView: LetterView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let letterTextViewPadding: CGFloat = 30
    }

    
    // MARK: - Views
    
    private let characterImageView = ImageView().then {
        $0.setSize(50)
    }

    
    // MARK: - View Life Cycle

    override func setup() {
        super.setup()
        
        letterTextView.isEditable = false
        letterTextView.isScrollEnabled = false
        backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(characterImageView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        letterTextView.snp.remakeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(Metric.letterTextViewPadding)
            make.trailing.equalToSuperview().inset(Metric.letterTextViewPadding)
            make.bottom.equalToSuperview().inset(Metric.letterTextViewPadding)
        }
    }
}

extension ResponseHistoryLetterView {
    func configure(with character: CounselingCharacter, response: String) {
        characterImageView.setImage(character.imageName)
        letterTextView.text = response
    }
}
