//
//  SettingMenuView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import UIKit

final class SettingMenuView: UIView {
    let titleLabel = UILabel().then {
        $0.textColor = AppColor.Text.main.color
        $0.font = .온글잎_의연체.subHeading
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    let valueLabel = UILabel().then {
        $0.textColor = AppColor.Text.fogHighlight.color
        $0.font = .온글잎_의연체.subHeading
        $0.textAlignment = .right
        $0.numberOfLines = 1
    }
    
    let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = AppColor.Text.fogHighlight.color
    }
    
    init(item: SettingMenuItem) {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        
        configure(with: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = .clear
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(chevronImageView)
    }
    
    func configure(with item: SettingMenuItem) {
        titleLabel.text = item.settingCase.title
        valueLabel.text = item.value
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        if item.isNavigatable {
            chevronImageView.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(15)
                make.width.equalTo(10)
            }
            
            valueLabel.snp.makeConstraints { make in
                make.trailing.equalTo(chevronImageView.snp.leading).offset(-5)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        } else {
            valueLabel.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }
    
    func changeThemeIfNeeded() {
        titleLabel.textColor = AppColor.Text.main.color
        valueLabel.textColor = AppColor.Text.fogHighlight.color
        chevronImageView.tintColor = AppColor.Text.fogHighlight.color
    }
}
