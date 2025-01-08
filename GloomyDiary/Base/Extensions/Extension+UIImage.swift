//
//  Extension+UIImage.swift
//  GloomyDiary
//
//  Created by 디해 on 9/7/24.
//

import UIKit

extension UIImage {
    static func downsample(imageAt imageURL: URL, within pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else { return nil }
        
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat,
              let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat else { return nil }
        
        let targetWidth = pointSize.width * scale
        let targetHeight = pointSize.height * scale
        let aspectWidth = targetWidth / pixelWidth
        let aspectHeight = targetHeight / pixelHeight
        let aspectRatio = min(aspectWidth, aspectHeight) 
        let maxDimensionInPixels = max(pixelWidth * aspectRatio, pixelHeight * aspectRatio)

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
    static func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else { return nil }
        
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat,
              let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat else { return nil }
        
        var maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        if pixelWidth < pixelHeight {
            maxDimensionInPixels = (pixelHeight * maxDimensionInPixels) / pixelWidth
        } else {
            maxDimensionInPixels = (pixelWidth * maxDimensionInPixels) / pixelHeight
        }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        
        let originImage = UIImage(cgImage: cgImage)
        let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
    func resized(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let imageRenderer = UIGraphicsImageRenderer(size: size)
        let frame = CGRect(origin: .zero, size: size)
        
        return imageRenderer.image { _ in self.draw(in: frame)}
    }
}
