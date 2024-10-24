//
//  ResultLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class ResultLetterView: LetterView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let copyButtonPadding: CGFloat = 20
    }
    
    
    // MARK: - Views
    
    let copyButton: RoundedIconButton = RoundedIconButton(size: 35,
                                                          iconName: "doc.on.doc",
                                                          iconSize: 15)
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        super.setup()
        
        letterTextView.isEditable = false
        backgroundColor = .component(.buttonPurple)
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(copyButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        copyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Metric.copyButtonPadding)
            make.bottom.equalToSuperview().inset(Metric.copyButtonPadding)
        }
    }
}
