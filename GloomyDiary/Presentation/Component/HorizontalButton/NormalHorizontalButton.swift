//
//  NormalHorizontalButton.swift
//  GloomyDiary
//
//  Created by 디해 on 4/23/25.
//

import UIKit

final class NormalHorizontalButton: HorizontalButton {
    override var isEnabled: Bool {
        didSet {
            setBackgroundColor()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            setBackgroundColor()
        }
    }
    
    override init() {
        super.init()
        
        setBackgroundColor()
        setFontColor()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setBackgroundColor() {
        if isHighlighted {
            self.backgroundColor = AppColor.Component.selectedHorizontalButton.color
        } else {
            if isEnabled {
                self.backgroundColor = AppColor.Component.horizontalButton.color
            } else {
                self.backgroundColor = AppColor.Component.disabledButton.color
            }
        }
    }
    
    private func setFontColor() {
        self.setTitleColor(AppColor.Text.main.color, for: .normal)
        self.setTitleColor(AppColor.Text.disabled.color, for: .disabled)
    }
    
    func changeThemeIfNeeded() {
        self.setBackgroundColor()
        self.setFontColor()
    }
}
