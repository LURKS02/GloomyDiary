//
//  Button.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class ButtonView: BaseView {
    private struct Matric {
        static let buttonWidth: CGFloat = 180
        static let buttonHeight: CGFloat = 56
        static let buttonCornerRadius: CGFloat = 28
    }
    
    let button: UIButton = UIButton().then {
        $0.titleLabel?.textColor = .text(.highlight)
        $0.titleLabel?.font = .무궁화.title
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.button.setTitle(text, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.backgroundColor = .component(.buttonPurple)
        self.layer.cornerRadius = Matric.buttonCornerRadius
        self.layer.masksToBounds = true
    }
    
    override func addSubviews() {
        addSubview(button)
    }
    
    override func setupConstraints() {
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(Matric.buttonHeight)
            make.width.equalTo(Matric.buttonWidth)
        }
    }
}
