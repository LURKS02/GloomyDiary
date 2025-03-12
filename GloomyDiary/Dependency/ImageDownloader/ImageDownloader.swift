//
//  ImageDownloader.swift
//  GloomyDiary
//
//  Created by 디해 on 3/11/25.
//

import Dependencies
import UIKit

struct ImageDownloader {
    var downloadImages: () async throws -> [UIImage]
}

private enum ImageDownloaderKey: DependencyKey {
    static var liveValue = ImageDownloader {
        let downloader = PicsumV2ImageDownloader()
        return try await downloader.downloadImages()
    }
    
    static var testValue = ImageDownloader {
        let downloader = RandomColorImageDownloader()
        return try await downloader.downloadImages()
    }
}

extension DependencyValues {
    var imageDownloader: ImageDownloader {
        get { self[ImageDownloaderKey.self] }
        set { self[ImageDownloaderKey.self] }
    }
}
