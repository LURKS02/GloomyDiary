//
//  IntroduceView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/24/24.
//

import UIKit

final class NormalLabel: UILabel {
    init() {
        super.init(frame: .zero)
        
        self.textColor = AppColor.Text.main.color
        self.font = .온글잎_의연체.title
        self.textAlignment = .center
        self.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeThemeIfNeeded() {
        self.textColor = AppColor.Text.main.color
    }
}
