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
    
    private let maxPage = 10
    
    func prepareEnvironment() async {
        await prepareCounselingSessions()
    }
}

extension TestEnvironmentManager {
    private func prepareCounselingSessions() async {
        var ids = ImageCache.shared.readIDs()
        
        if ids.isEmpty {
            let jsons = await fetchImageJSON(maxPage: maxPage)
            let imageURLs = jsons.compactMap { json -> URL? in
                guard let urlString = json["download_url"] as? String else { return nil }
                return URL(string: urlString)
            }
            
            for url in imageURLs {
                do {
                    guard let imageData = try await fetchData(from: url) else { return }
                    
                    let id = try ImageCache.shared.saveImageDataToDisk(imageData)
                    ids.append(id)
                    print(">>>", ids.count)
                } catch {
                    print(error)
                }
            }
        }
        
        try? await counselingSessionRepository.initialize()
        await createSessions(with: ids)
    }
    
    private func createSessions(with imageIDs: [UUID]) async {
        let sessions = stride(from: 0, to: imageIDs.count, by: 3).map { index in
            let ids = (0..<3).compactMap { offset in
                let idIndex = index + offset
                return idIndex < imageIDs.count ? imageIDs[idIndex] : nil
            }
            
            let session = Session(id: UUID(),
                                  counselor: CounselingCharacter.getRandomElement(),
                                  title: "테스트",
                                  query: "테스트 쿼리",
                                  response: "테스트 리스폰스",
                                  createdAt: .now,
                                  weather: Weather.getRandomElement(),
                                  emoji: Emoji.getRandomElement(),
                                  imageIDs: ids)
            
            return session
        }
        
        await withTaskGroup(of: Void.self) { group in
            for session in sessions {
                group.addTask {
                    try? await self.counselingSessionRepository.create(session)
                }
            }
        }
        
        try? await counselingSessionRepository.save()
    }
    
    private func fetchImageJSON(maxPage: Int) async -> [[String: Any]] {
        var datas: [[String: Any]] = []
        let baseURL = "https://picsum.photos/v2/list"
        
        for page in 1...maxPage {
            let params = "?page=\(page)&limit=\(100)"
            guard let url = URL(string: baseURL + params) else { continue }
            
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return [] }
            
            datas.append(contentsOf: json)
        }
        
        return datas
    }
    
    private func fetchData(from url: URL) async throws -> Data? {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10000
        configuration.timeoutIntervalForResource = 10000
        let session = URLSession(configuration: configuration)
        
        let (data, _) = try await session.data(from: url)
        return data
    }
}

private extension ImageCache {
    @discardableResult
    func saveImageDataToDisk(_ data: Data) throws -> UUID {
        let id = UUID()
        
        guard let image = UIImage(data: data) else { throw LocalError(message: "invalid image") }
        return try saveImageToDisk(image: image)
    }
}
