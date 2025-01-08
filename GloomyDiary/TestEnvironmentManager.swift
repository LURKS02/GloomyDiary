//
//  TestEnvironmentManager.swift
//  GloomyDiary
//
//  Created by 디해 on 12/21/24.
//

import Foundation
import Dependencies

final class TestEnvironmentManager {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    
    private let maxPage = 10
    
    func prepareEnvironment() async {
        await prepareCounselingSessions()
    }
}

extension TestEnvironmentManager {
    private func prepareCounselingSessions() async {
        var urls = loadImagesFromDisk()
        
        if urls.isEmpty {
            let jsons = await fetchImageJSON(maxPage: maxPage)
            let imageURLs = jsons.compactMap { json -> URL? in
                guard let urlString = json["download_url"] as? String else { return nil }
                return URL(string: urlString)
            }
            
            let datas = await fetchData(from: imageURLs)
            saveImagesToDisk(datas: datas)
            urls = loadImagesFromDisk()
        }
        
        try? await counselingSessionRepository.initialize()
        await createSessions(with: urls)
    }
    
    private func createSessions(with urls: [URL]) async {
        let sessions = stride(from: 0, to: urls.count, by: 3).map { index in
            let imageURLs = (0..<3).compactMap { offset in
                let urlIndex = index + offset
                return urlIndex < urls.count ? urls[urlIndex] : nil
            }
            
            let sessionDTO = CounselingSessionDTO(id: UUID(),
                                                  counselor: CharacterDTO.getRandomElement(),
                                                  title: "테스트",
                                                  query: "테스트 쿼리",
                                                  response: "테스트 리스폰스",
                                                  createdAt: .now,
                                                  weather: WeatherDTO.getRandomElement(),
                                                  emoji: EmojiDTO.getRandomElement(),
                                                  urls: imageURLs)
            
            return sessionDTO
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
    
    private func loadImagesFromDisk() -> [URL] {
        return ImageFileManager.shared.getAllImageURL()
    }
    
    private func saveImagesToDisk(datas: [Data]) {
        datas.enumerated().forEach { (index, data) in
            _ = try? ImageFileManager.shared.write(data: data, fileName: "image_\(index).jpg")
        }
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
    
    private func fetchData(from urls: [URL]) async -> [Data] {
        var result: [Data] = []
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10000
        configuration.timeoutIntervalForResource = 10000
        let session = URLSession(configuration: configuration)
        
        await withTaskGroup(of: (Data?).self) { group in
            for url in urls {
                group.addTask {
                    do {
                        let (data, _) = try await session.data(from: url)
                        return data
                    } catch {
                        print(error)
                        return nil
                    }
                }
            }
            
            for await data in group {
                if let data = data { result.append(data) }
            }
        }
        
        return result
    }
}
