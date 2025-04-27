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
    
    private var character: CounselingCharacter = .chan

    
    // MARK: - Views
    
    private let characterImageView = UIImageView()

    
    // MARK: - View Life Cycle

    override func setup() {
        super.setup()
        
        letterTextView.isEditable = false
        letterTextView.isScrollEnabled = false
        backgroundColor = AppColor.Background.main.color
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
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        letterTextView.snp.remakeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(Metric.letterTextViewPadding)
            make.trailing.equalToSuperview().inset(Metric.letterTextViewPadding)
            make.bottom.equalToSuperview().inset(Metric.letterTextViewPadding)
        }
    }
    
    override func changeThemeIfNeeded() {
        super.changeThemeIfNeeded()
        
        backgroundColor = AppColor.Background.main.color
        characterImageView.image = AppImage.Character.counselor(character, .normal).image
    }
}

extension ResponseHistoryLetterView {
    func configure(with character: CounselingCharacter, response: String) {
        self.character = character
        characterImageView.image = AppImage.Character.counselor(character, .normal).image
        letterTextView.text = response
    }
}
