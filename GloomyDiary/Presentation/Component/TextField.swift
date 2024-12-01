//
//  TextField.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit
import RxCocoa
import RxSwift

final class TextField: UIView {
    private let textField = UITextField().then {
        $0.font = .무궁화.title
        $0.textColor = .text(.highlight)
    }
    
    var text: String? {
        textField.text
    }
    
    var textControlProperty: ControlProperty<String?> {
        textField.rx.text
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = .component(.textFieldGray)
        self.applyCornerRadius(20)
    }
    
    private func addSubviews() {
        addSubview(textField)
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
        }
    }
}
