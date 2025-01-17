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
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
    func resized(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let imageRenderer = UIGraphicsImageRenderer(size: size)
        let frame = CGRect(origin: .zero, size: size)
        
        return imageRenderer.image { _ in self.draw(in: frame) }
    }
    
    func resizedToSquare(sidePixel: CGFloat) -> UIImage? {
        let screenScale = UIScreen.main.scale
        let side = sidePixel / screenScale
        
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        
        let scaleFactor = max(side / originalWidth, side / originalHeight)
        let targetWidth = originalWidth * scaleFactor
        let targetHeight = originalHeight * scaleFactor
        
        let size = CGSize(width: targetWidth, height: targetHeight)
        
        let frame = CGRect(
            x: (size.width - side) / 2.0,
            y: (size.height - side) / 2.0,
            width: side,
            height: side)
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { _ in
            self.draw(in: CGRect(origin: CGPoint(x: -frame.origin.x, y: -frame.origin.y), size: size))
        }
    }
    
    func resizedToFit(pixelWidth: CGFloat, pixelHeight: CGFloat) -> UIImage? {
        let originalWidth = self.size.width * self.scale
        let originalHeight = self.size.height * self.scale
        
        if originalWidth <= pixelWidth && originalHeight <= pixelHeight {
            return self
        }
        
        let widthRatio = pixelWidth / originalWidth
        let heightRatio = pixelHeight / originalHeight
        let scaleFactor = min(widthRatio, heightRatio)
        
        let targetWidth = originalWidth * scaleFactor
        let targetHeight = originalHeight * scaleFactor
        
        let size = CGSize(width: targetWidth / UIScreen.main.scale, height: targetHeight / UIScreen.main.scale)
        let frame = CGRect(origin: .zero, size: size)

        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.prefersExtendedRange = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { _ in self.draw(in: frame) }
    }
}
