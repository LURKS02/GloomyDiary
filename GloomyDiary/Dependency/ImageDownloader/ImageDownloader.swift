//
//  ImageDownloader.swift
//  GloomyDiary
//
//  Created by 디해 on 3/11/25.
//

import Combine
import Dependencies
import UIKit

struct ImageDownloader {
    var downloadImages: () async throws -> [UIImage]
    var progressSubject: PassthroughSubject<(Int, Int), Never>
}

private enum ImageDownloaderKey: DependencyKey {
    static var liveValue = {
        let picsumDownloader = PicsumV2ImageDownloader()
        return ImageDownloader(
            downloadImages: picsumDownloader.downloadImages,
            progressSubject: picsumDownloader.progressSubject
        )
    }()
    
    static var testValue = {
        let colorDownloader = RandomColorImageDownloader()
        return ImageDownloader(
            downloadImages: colorDownloader.downloadImages,
            progressSubject: colorDownloader.progressSubject
        )
    }()
}

extension DependencyValues {
    var imageDownloader: ImageDownloader {
        get { self[ImageDownloaderKey.self] }
        set { self[ImageDownloaderKey.self] }
    }
}
