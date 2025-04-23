//
//  SubHorizontalButton.swift
//  GloomyDiary
//
//  Created by 디해 on 4/23/25.
//

import UIKit

final class SubHorizontalButton: HorizontalButton {
    private var theme: AppearanceMode = AppEnvironment.appearanceMode
    
    override var isEnabled: Bool {
        didSet {
            setBackgroundColor(theme: theme)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            setBackgroundColor(theme: theme)
        }
    }
    
    override init() {
        super.init()
        
        setBackgroundColor(theme: theme)
        setFontColor(theme: theme)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setBackgroundColor(theme: AppearanceMode) {
        if isHighlighted {
            self.backgroundColor = AppColor.Component.selectedHorizontalButton.color(for: theme)
        } else {
            if isEnabled {
                self.backgroundColor = AppColor.Component.subHorizontalButton.color(for: theme)
            } else {
                self.backgroundColor = AppColor.Component.disabledButton.color(for: theme)
            }
        }
    }
    
    private func setFontColor(theme: AppearanceMode) {
        self.setTitleColor(AppColor.Text.main.color(for: theme), for: .normal)
        self.setTitleColor(AppColor.Text.disabled.color(for: theme), for: .disabled)
    }
    
    func changeTheme(_ theme: AppearanceMode) {
        self.theme = theme
        self.setBackgroundColor(theme: theme)
        self.setFontColor(theme: theme)
    }
}
