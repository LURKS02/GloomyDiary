//
//  ResponseHistoryLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class ResponseHistoryLetterView: LetterView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let letterTextViewPadding: CGFloat = 30
    }

    
    // MARK: - Views
    
    private let characterImageView = ImageView().then {
        $0.setSize(50)
    }
    
    private let characterInformationLabel = UILabel().then {
        $0.font = .무궁화.body
        $0.textAlignment = .center
        $0.textColor = .text(.subHighlight)
    }

    
    // MARK: - View Life Cycle

    override func setup() {
        super.setup()
        
        letterTextView.isEditable = false
        letterTextView.isScrollEnabled = false
        backgroundColor = .component(.buttonPurple)
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(characterImageView)
        addSubview(characterInformationLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(30)
        }
        
        characterInformationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(characterImageView)
            make.leading.equalTo(characterImageView.snp.trailing).offset(10)
        }
        
        letterTextView.snp.remakeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(15)
            make.leading.equalToSuperview().inset(Metric.letterTextViewPadding)
            make.trailing.equalToSuperview().inset(Metric.letterTextViewPadding)
            make.bottom.equalToSuperview().inset(Metric.letterTextViewPadding)
        }
    }
}

extension ResponseHistoryLetterView {
    func configure(with character: CharacterDTO, response: String) {
        characterImageView.setImage(character.imageName)
        characterInformationLabel.text = "상담사: \(character.name)"
        letterTextView.text = response
    }
}
