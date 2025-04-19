//
//  ResultLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class ResultLetterView: LetterView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let copyButtonPadding: CGFloat = 20
    }
    
    
    // MARK: - Views
    
    let copyButton: RoundedIconButton = RoundedIconButton(
        size: 35,
        iconName: "doc.on.doc",
        iconSize: 15
    )
    
    private let gradientBackgroundView = GradientView(
        colors: [
            AppColor.Component.horizontalButton.color.withAlphaComponent(0.0),
            AppColor.Component.horizontalButton.color
        ],
        locations: [0.0, 0.5, 1.0]
    )
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        super.setup()
        
        letterTextView.isEditable = false
        backgroundColor = AppColor.Background.letter.color
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(gradientBackgroundView)
        addSubview(copyButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        gradientBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(70)
        }
        
        copyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Metric.copyButtonPadding)
            make.bottom.equalToSuperview().inset(Metric.copyButtonPadding)
        }
    }
}
