//
//  SettingView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import UIKit

final class SettingView: UIView {
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = AppColor.Background.main.color
    }
}
