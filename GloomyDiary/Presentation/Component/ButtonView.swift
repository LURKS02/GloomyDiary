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
    
    private let buttonLabel: UILabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.font = .무궁화.title
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.buttonLabel.text = text
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
        addSubview(buttonLabel)
    }
    
    override func setupConstraints() {
        buttonLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(Matric.buttonHeight)
            make.width.equalTo(Matric.buttonWidth)
        }
    }
}
