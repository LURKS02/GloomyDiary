//
//  CancelButton.swift
//  GloomyDiary
//
//  Created by 디해 on 12/18/24.
//

import UIKit

final class CancelButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .black.withAlphaComponent(0.5)
        setImage(UIImage(systemName: "xmark"), for: .normal)
        tintColor = .white
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 8)
        setPreferredSymbolConfiguration(imageConfiguration, forImageIn: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.applyCircularShape()
    }
}
