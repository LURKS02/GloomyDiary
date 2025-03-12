//
//  PicsumV2ImageDownloader.swift
//  GloomyDiary
//
//  Created by 디해 on 3/11/25.
//

import UIKit

final class PicsumV2ImageDownloader {
    private let maxPage = 1
    private let pageLimit = 30
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.timeoutIntervalForResource = 300
        return URLSession(configuration: configuration)
    }()
    
    func downloadImages() async throws -> [UIImage] {
        
        let jsons = try await fetchImageJSON(maxPage: maxPage)
        let imageURLs = convertJSONToImageURL(jsons)
        let images = try await downloadImages(from: imageURLs)
        
        return images
    }
}

extension PicsumV2ImageDownloader {
    
    private func fetchImageJSON(maxPage: Int) async throws -> [[String: Any]] {
        let baseURL = "https://picsum.photos/v2/list"
        
        return try await withThrowingTaskGroup(of: [[String: Any]].self) { group in
            let urls: [URL] = try (1...maxPage).map { page in
                let params = "?page=\(page)&limit=\(pageLimit)"
                guard let url = URL(string: baseURL + params) else { throw CancellationError() }
                return url
            }
            
            var datas: [[String: Any]] = []
            
            for url in urls {
                let added = group.addTaskUnlessCancelled {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    try Task.checkCancellation()
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { throw CancellationError() }
                    
                    return json
                }
            
                guard added else { break }
            }
            
            while !group.isEmpty {
                do {
                    guard let json = try await group.next() else { throw CancellationError() }
                    datas.append(contentsOf: json)
                } catch {
                    group.cancelAll()
                    throw CancellationError()
                }
            }
            
            return datas
        }
    }
    
    private func convertJSONToImageURL(_ jsons: [[String: Any]]) -> [URL] {
        let urls = jsons.compactMap { json -> URL? in
            guard let urlString = json["download_url"] as? String else { return nil }
            return URL(string: urlString)
        }
        
        return urls
    }
    
    private func downloadImages(from urls: [URL]) async throws -> [UIImage] {
        var images: [UIImage] = []
        
        for url in urls {
            let (imageData, _) = try await session.data(from: url)
            if let image = UIImage(data: imageData) {
                images.append(image)
            }
            
            print(">>> \(url)")
            
//            try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
        }
        
        return images
    }
}
