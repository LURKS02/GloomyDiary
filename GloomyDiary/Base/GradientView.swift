//
//  GradientView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class GradientView: BaseView {
    private let gradientLayer = CAGradientLayer().then {
        $0.startPoint = CGPoint(x: 0.5, y: 0)
        $0.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    init(colors: [UIColor], locations: [NSNumber]? = nil) {
        super.init(frame: .zero)
        
        gradientLayer.colors = colors.map { $0.cgColor }
        
        if let locations { gradientLayer.locations = locations }
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}
