//
//  ImageCache.swift
//  GloomyDiary
//
//  Created by 디해 on 1/15/25.
//

import UIKit
import AVFoundation

final class ImageCache {
    enum FetchOption {
        case fromCache
        case fromDisk
    }
    
    enum ContentMode {
        case scaleAspectFit
        case scaleAspectFill
    }
    
    static let shared = ImageCache()
    
    private init() {
        try? fileManager.createDirectory(at: thumbnailDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        memoryCache.totalCostLimit = 5 * 1024 * 1024
    }
    
    private let memoryCache = Cache<UUID, UIImage>()
    private let fileManager = FileManager.default
    
    private let thumbnailDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("Thumbnails")
    }()
    private var imageDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("images")
    }()
    
    // MARK: - get image
    
    func getThumbnailImage(
        forKey key: UUID,
        pointSize: CGSize,
        fetchOption: FetchOption = .fromCache
    ) throws -> UIImage {
        switch fetchOption {
        case .fromCache:
            if let memoryCachedImage = memoryCache.value(forKey: key) {
                return memoryCachedImage
            }
            if let diskImage = getThumbnailImageFromDisk(forKey: key, pointSize: pointSize) {
                return diskImage
            }
            if let prevImage = getThumbnailImageFromDisk(forKey: key, pointSize: pointSize) { return prevImage }
            
        case .fromDisk:
            if let diskImage = getThumbnailImageFromDisk(forKey: key, pointSize: pointSize) { return diskImage }
            if let prevImage = getThumbnailImageFromDisk(forKey: key, pointSize: pointSize) { return prevImage }
        }
        
        throw LocalError(message: "Thumbnail image fetch error")
    }
    
    func getImage(
        forKey key: UUID,
        pointSize: CGSize,
        mode: ContentMode = .scaleAspectFill
    ) throws -> UIImage {
        if let originalImage = getOriginalImageFromDisk(forKey: key, pointSize: pointSize, mode: mode) {
            return originalImage
        }
        
        if let prevImage = getOriginalImageFromPrevDisk(forKey: key, pointSize: pointSize, mode: mode) {
            return prevImage
        }
        
        return UIImage()
    }
    
    
    // MARK: - from Image disk
    
    private func getThumbnailImageFromDisk(forKey key: UUID, pointSize: CGSize) -> UIImage? {
        let filePath = thumbnailDirectory.appendingPathComponent("thumbnail_\(key).jpeg")
        guard let image = UIImage.downsample(imageAt: filePath, to: pointSize) else { return nil }
        
        DispatchQueue.global().async { [weak self] in
            self?.cacheImageInMemory(image, forKey: key)
        }
        
        return image
    }
    
    private func getOriginalImageFromDisk(forKey key: UUID, pointSize: CGSize, mode: ContentMode) -> UIImage? {
        let filePath = imageDirectory.appendingPathComponent("image_\(key).heic")
        let downsampledImage: UIImage?
        
        switch mode {
        case .scaleAspectFit:
            downsampledImage = UIImage.downsample(imageAt: filePath, within: pointSize)
        case .scaleAspectFill:
            downsampledImage = UIImage.downsample(imageAt: filePath, to: pointSize)
        }
        guard let downsampledImage else { return nil }
        
        return downsampledImage
    }

    
    // MARK: - from Prev image disk

    private func getThumbnailImageFromPrevDisk(forKey key: UUID, pointSize: CGSize) -> UIImage? {
        let filePath = imageDirectory.appendingPathComponent("image_\(key).jpg")
        guard let image = UIImage(contentsOfFile: filePath.path()),
              let downsampledImage = UIImage.downsample(imageAt: filePath, to: pointSize) else { return nil }
        
        DispatchQueue.global().async { [weak self] in
            try? self?.saveImageToDisk(image: image)
            try? self?.fileManager.removeItem(at: filePath)
        }
        
        return downsampledImage
    }
    
    private func getOriginalImageFromPrevDisk(forKey key: UUID, pointSize: CGSize, mode: ContentMode) -> UIImage? {
        let filePath = imageDirectory.appendingPathComponent("image_\(key).jpg")
        guard let image = UIImage(contentsOfFile: filePath.path()) else { return nil }
        let downsampledImage: UIImage?
        
        switch mode {
        case .scaleAspectFit:
            downsampledImage = UIImage.downsample(imageAt: filePath, within: pointSize)
        case .scaleAspectFill:
            downsampledImage = UIImage.downsample(imageAt: filePath, to: pointSize)
        }
        
        guard let downsampledImage else { return nil }
        
        DispatchQueue.global().async { [weak self] in
            try? self?.saveImageToDisk(image: image)
            try? self?.fileManager.removeItem(at: filePath)
        }
        
        return downsampledImage
    }
    
    
    // MARK: - save image

    private func cacheImageInMemory(_ image: UIImage, forKey key: UUID) {
        let cost = Int(image.size.width * image.size.height) * 4
        
        memoryCache.setValue(image, forKey: key, cost: cost)
    }
    
    @discardableResult
    func saveImageToDisk(_ id: UUID = UUID(), image: UIImage) throws -> UUID {
        do {
            try saveHEICImage(id: id, image: image)
            try saveThumbnail(id: id, image: image)
            return id
        } catch {
            deleteSavedFiles(id: id)
            throw error
        }
    }
    
    private func saveHEICImage(id: UUID, image: UIImage) throws {
        guard let resizedImage = image.resizedToFit(pixelWidth: 1500, pixelHeight: 3000),
              let cgImage = resizedImage.cgImage
        else { throw LocalError(message: "Invalid CGImage") }
        
        let filePath = imageDirectory.appendingPathComponent("image_\(id).heic")
        
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 0.7,
            kCGImageDestinationMetadata: [:]
        ]
        
        guard let destination = CGImageDestinationCreateWithURL(
            filePath as CFURL,
            AVFileType.heic as CFString,
            1,
            nil
        ) else { throw LocalError(message: "CGImage destination error") }
        
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        
        if !CGImageDestinationFinalize(destination) { throw LocalError(message: "CGImage destination finalize error") }
    }
    
    private func saveThumbnail(id: UUID, image: UIImage) throws {
        guard let thumbnailImage = image.resizedToSquare(sidePixel: 300),
              let jpegData = thumbnailImage.jpegData(compressionQuality: 0.3)
        else { throw LocalError(message: "jpeg data error") }
        
        let filePath = thumbnailDirectory.appendingPathComponent("thumbnail_\(id).jpeg")
        
        try jpegData.write(to: filePath)
    }
    
    
    // MARK: - delete image
    
    func deleteAllFiles() throws {
        let imageURLs = try fileManager.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
        let thumbnailURLs = try fileManager.contentsOfDirectory(at: thumbnailDirectory, includingPropertiesForKeys: nil)
        
        for url in imageURLs {
            try fileManager.removeItem(at: url)
        }
        
        for url in thumbnailURLs {
            try fileManager.removeItem(at: url)
        }
    }
    
    private func deleteSavedFiles(id: UUID) {
        let filePath = imageDirectory.appendingPathComponent("image_\(id).heic")
        let thumbnailPath = thumbnailDirectory.appendingPathComponent("thumbnail_\(id).jpeg")
        
        if fileManager.fileExists(atPath: filePath.path()) {
            try? fileManager.removeItem(at: filePath)
        }
        if fileManager.fileExists(atPath: thumbnailPath.path()) {
            try? fileManager.removeItem(at: thumbnailPath)
        }
    }
}
