//
//  LetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

class LetterView: BaseView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let letterTextViewPadding: CGFloat = 30
    }
    
    let letterTextView: UITextView = UITextView().then {
        $0.font = .무궁화.title
        $0.textColor = .text(.highlight)
        $0.textAlignment = .left
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }
    
    // MARK: - View Life Cycle
    
    override func setup() {
        applyCornerRadius(20)
    }
    
    override func addSubviews() {
        addSubview(letterTextView)
    }
    
    override func setupConstraints() {
        letterTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metric.letterTextViewPadding)
        }
    }
}
