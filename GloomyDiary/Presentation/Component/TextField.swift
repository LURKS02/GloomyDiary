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
    private lazy var textField = UITextField().then {
        $0.font = .무궁화.title
        $0.textColor = .text(.highlight)
        $0.delegate = self
    }
    
    let textSubject = BehaviorSubject<String>(value: "")
    
    private let maxCount: Int = 25
    
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
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
        }
    }
}

extension TextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        guard newText.count <= maxCount else { return false }
        
        textSubject.onNext(newText)
        return true
    }
}
