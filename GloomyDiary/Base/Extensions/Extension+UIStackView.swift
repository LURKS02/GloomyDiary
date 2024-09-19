//
//  Extension+UIStackView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/7/24.
//

import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        for subview in self.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
}
