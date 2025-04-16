//
//  TextField.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Combine
import CombineCocoa
import UIKit

final class RoundTextField: UIView {
    let textField = UITextField().then {
        $0.font = .온글잎_의연체.title
        $0.textColor = AppColor.Text.highlight.color
    }
    
    var textPublisher: AnyPublisher<String?, Never> {
        textField.textPublisher
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
        self.backgroundColor = AppColor.Component.textFieldGray.color
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
