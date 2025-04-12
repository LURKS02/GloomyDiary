//
//  TestEnvironmentManager.swift
//  GloomyDiary
//
//  Created by 디해 on 12/21/24.
//

import AVFoundation
import Combine
import Dependencies
import Foundation
import UIKit.UIImage

final class TestEnvironmentManager {
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    @Dependency(\.imageDownloader) var imageDownloader
    
    weak var delegate: TestEnvironmentManagerDelegate?
    
    var cancellables = Set<AnyCancellable>()
    
    private let testImageDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("testImages")
    }()
    
    func prepareEnvironment() async {
        do {
            imageDownloader.progressSubject.sink { [weak self] (progressedCount, totalCount) in
                self?.delegate?.didUpdateProcess("이미지 다운로드 중...\n\(progressedCount)/\(totalCount)개 완료.")
            }.store(in: &cancellables)
            
            delegate?.didUpdateProcess("환경 설정을 시작합니다.")
            try await prepareCounselingSessions()
            delegate?.didUpdateProcess("환경 설정을 완료하였습니다.")
        } catch {
            delegate?.didUpdateProcess("오류 발생: \(error)")
        }
    }
}

extension TestEnvironmentManager {
    private func prepareCounselingSessions() async throws {
        delegate?.didUpdateProcess("테스트 이미지 ID 로드 중 ...")
        var ids = await loadTestImageIDs()
        
        if ids.isEmpty {
            delegate?.didUpdateProcess("테스트 이미지가 존재하지 않습니다.\n다운로드를 시작합니다.")
            
            let images = try await imageDownloader.downloadImages()
            delegate?.didUpdateProcess("\(images.count)개의 이미지 다운로드 완료.\n이미지를 저장합니다.")
            let imageIDs = await saveImagesToLocal(images)
            ids = imageIDs
            delegate?.didUpdateProcess("\(ids.count)개의 이미지 저장 완료.")
        }
        
        delegate?.didUpdateProcess("기존 데이터를 제거하고\n테스트 이미지로 데이터를 다시 생성합니다.")
        try await counselingSessionRepository.deleteAll()
        try ImageCache.shared.deleteAllFiles()
        
        ids.sort()
        
        try await createResizedImages(with: ids)
        try await createSessions(with: ids)
        
        delegate?.didFinishPreparing()
    }
    
    func loadTestImageIDs() async -> [UUID] {
        await withTaskGroup(of: Optional<UUID>.self, returning: [UUID].self) { group in
            guard let fileURLs = try? FileManager.default.contentsOfDirectory(
                at: testImageDirectory,
                includingPropertiesForKeys: nil
            ) else { return [] }
            
            for fileURL in fileURLs {
                group.addTask {
                    let fileName = fileURL.lastPathComponent
                    let fileExtension = fileURL.pathExtension
                    
                    guard fileExtension.lowercased() == "heic" else { return nil }
                    
                    if fileName.hasPrefix("image_"),
                       let range = fileName.range(of: "image_") {
                        let uuidPart = fileName[range.upperBound...].dropLast(fileExtension.count + 1)
                        return UUID(uuidString: String(uuidPart))
                    }
                    
                    return nil
                }
            }
            
            var imageIDs: [UUID] = []
            for await imageID in group {
                guard let imageID else { continue }
                imageIDs.append(imageID)
            }
            
            return imageIDs
        }
    }
    
    private func saveImagesToLocal(_ images: [UIImage]) async -> [UUID] {
        return await withTaskGroup(of: Optional<UUID>.self) { group in
            var imageIDs: [UUID] = []
            
            for image in images {
                group.addTask {
                    do {
                        let id = UUID()
                        guard let cgImage = image.cgImage else { return nil }
                        
                        if !FileManager.default.fileExists(atPath: self.testImageDirectory.path()) {
                            try FileManager.default.createDirectory(at: self.testImageDirectory, withIntermediateDirectories: true)
                        }
                        
                        let fileURL = self.testImageDirectory.appendingPathComponent("image_\(id).heic")
                        
                        let options: [CFString: Any] = [
                            kCGImageDestinationLossyCompressionQuality: 1.0,
                            kCGImageDestinationMetadata: [:]
                        ]
                        
                        guard let destination = CGImageDestinationCreateWithURL(
                            fileURL as CFURL,
                            AVFileType.heic as CFString,
                            1,
                            nil
                        ) else { return nil }
                        
                        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
                        if !CGImageDestinationFinalize(destination) { return nil }
                        return id
                    } catch {
                        print(error)
                        return nil
                    }
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
    
    private func createResizedImages(with imageIDs: [UUID]) async throws {
        await withTaskGroup(of: Optional<UUID>.self) { group in
            for imageID in imageIDs {
                group.addTask {
                    let filePath = self.testImageDirectory.appendingPathComponent("image_\(imageID).heic")
                    guard let imageData = try? Data(contentsOf: filePath),
                          let image = UIImage(data: imageData) else { return nil }
                    
                    let id = try? ImageCache.shared.saveImageToDisk(imageID, image: image)
                    
                    return id
                }
            }
        }
    }
    
    private func createSessions(with imageIDs: [UUID]) async throws {
        for index in stride(from: 0, to: imageIDs.count, by: 3) {
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
        
        try await counselingSessionRepository.save()
    }
    
    private func deleteAllTestImages() async {
        await withTaskGroup(of: Void.self) { group in
            guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: testImageDirectory, includingPropertiesForKeys: nil) else { return }

            for fileURL in fileURLs {
                group.addTask {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        }
    }
}
