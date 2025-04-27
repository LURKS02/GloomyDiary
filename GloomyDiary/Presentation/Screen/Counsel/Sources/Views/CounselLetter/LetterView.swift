//
//  LetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

class LetterView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let letterTextViewPadding: CGFloat = 30
    }
    
    let letterTextView: UITextView = UITextView().then {
        $0.font = .온글잎_의연체.title
        $0.textColor = AppColor.Text.main.color
        $0.textAlignment = .left
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    func setup() {
        applyCornerRadius(20)
    }
    
    func addSubviews() {
        addSubview(letterTextView)
    }
    
    func setupConstraints() {
        letterTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metric.letterTextViewPadding)
        }
    }
    
    func changeThemeIfNeeded() {
        letterTextView.textColor = AppColor.Text.main.color
    }
}
