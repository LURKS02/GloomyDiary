//
//  Extension+UIImage.swift
//  GloomyDiary
//
//  Created by 디해 on 9/7/24.
//

import UIKit

extension UIImage {
    func resized(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let imageRenderer = UIGraphicsImageRenderer(size: size)
        let frame = CGRect(origin: .zero, size: size)
        
        return imageRenderer.image { _ in self.draw(in: frame)}
    }
}
