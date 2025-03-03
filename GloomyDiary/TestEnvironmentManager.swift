//
//  TestEnvironmentManager.swift
//  GloomyDiary
//
//  Created by 디해 on 12/21/24.
//

import Foundation
import Dependencies
import UIKit.UIImage

final class TestEnvironmentManager {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    
    private let maxPage = 5
    private let pageLimit = 30
    
    private let imageDataSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.timeoutIntervalForResource = 300
        return URLSession(configuration: configuration)
    }()
    
    func prepareEnvironment() async {
        do {
            try await prepareCounselingSessions()
        } catch {
            print(error)
        }
    }
}

extension TestEnvironmentManager {
    private func prepareCounselingSessions() async throws {
        var ids = await ImageCache.shared.loadImageIDsFromDisk()
        
        if ids.isEmpty {
            let imageIDs = try await downloadImages()
            ids = imageIDs
        }
        
        ids.sort()
        
        try await counselingSessionRepository.deleteAll()
        try await createSessions(with: ids)
    }
    
    private func downloadImages() async throws -> [UUID] {
        let jsons = try await fetchImageJSON(maxPage: maxPage)
        let imageURLs = convertJSONToImageURL(jsons)
        let imageDatas = try await downloadImageDatas(from: imageURLs)
        let imageIDs = await saveImagesToLocal(imageDatas)
        
        return imageIDs
    }
    
    private func createSessions(with imageIDs: [UUID]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in stride(from: 0, to: imageIDs.count, by: 3) {
                let added = group.addTaskUnlessCancelled {
                    let ids = (0..<3).compactMap { offset in
                        let idIndex = index + offset
                        return idIndex < imageIDs.count ? imageIDs[idIndex] : nil
                    }
                    
                    let session = Session(
                        id: UUID(),
                        counselor: CounselingCharacter.getRandomElement(),
                        title: "테스트",
                        query: "테스트 쿼리",
                        response: "테스트 리스폰스",
                        createdAt: .now,
                        weather: Weather.getRandomElement(),
                        emoji: Emoji.getRandomElement(),
                        imageIDs: ids
                    )
                    
                    try await self.counselingSessionRepository.create(session)
                }
                
                guard added else { break }
            }
            
            while !group.isEmpty {
                do {
                    try await group.next()
                } catch {
                    group.cancelAll()
                    try await counselingSessionRepository.deleteAll()
                    throw CancellationError()
                }
            }
        }
        
        try await counselingSessionRepository.save()
    }
    
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
    
    private func downloadImageDatas(from urls: [URL]) async throws -> [Data] {
        var datas: [Data] = []
        
        for url in urls {
            let (imageData, _) = try await imageDataSession.data(from: url)
            datas.append(imageData)
            
            try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
        }
        
        return datas
    }
    
    private func saveImagesToLocal(_ datas: [Data]) async -> [UUID] {
        return await withTaskGroup(of: Optional<UUID>.self) { group in
            var imageIDs: [UUID] = []
            
            for data in datas {
                group.addTask {
                    guard let id = try? ImageCache.shared.saveImageDataToDisk(data) else { return nil }
                    return id
                }
            }
            
            for await id in group {
                if let id {
                    imageIDs.append(id)
                }
            }
            
            return imageIDs
        }
    }
}

private extension ImageCache {
    @discardableResult
    func saveImageDataToDisk(_ data: Data) throws -> UUID {
        guard let image = UIImage(data: data) else {
            throw LocalError(message: "invalid image")
        }
        
        return try saveImageToDisk(image: image)
    }
}
