//
//  MockImageDownloader.swift
//  GloomyDiary
//
//  Created by 디해 on 3/11/25.
//

import Combine
import UIKit

final class RandomColorImageDownloader {
    var progressSubject = PassthroughSubject<(Int, Int), Never>()
    
    func downloadImages() async throws -> [UIImage] {
        return await withTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []
            
            for _ in 0..<900 {
                group.addTask {
                    return self.generateRandomColorImage(size: CGSize(width: 100, height: 100))
                }
            }
            
            for await image in group {
                images.append(image)
                progressSubject.send((images.count, 900))
            }
            
            return images
        }
    }
    
    private func generateRandomColorImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let randomColor = UIColor(
                red: CGFloat.random(in: 0...1),
                green: CGFloat.random(in: 0...1),
                blue: CGFloat.random(in: 0...1),
                alpha: 1.0
            )
            randomColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
