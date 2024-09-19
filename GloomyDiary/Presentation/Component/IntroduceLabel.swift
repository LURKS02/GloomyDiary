//
//  IntroduceView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class IntroduceLabel: UILabel {
    init() {
        super.init(frame: .zero)
        
        self.textColor = .text(.highlight)
        self.font = .무궁화.title
        self.textAlignment = .center
        self.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
