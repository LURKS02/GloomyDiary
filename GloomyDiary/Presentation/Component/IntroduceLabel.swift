//
//  IntroduceView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class IntroduceLabel: BaseView {
    private let introduceLabel: UILabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.font = .무궁화.title
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override func setup() {
    }
    
    override func addSubviews() {
        addSubview(introduceLabel)
    }
    
    override func setupConstraints() {
        introduceLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func update(text: String) {
        introduceLabel.text = text
    }
}
