//
//  ImageFileManager.swift
//  GloomyDiary
//
//  Created by 디해 on 12/30/24.
//

import Foundation

final class ImageFileManager {
    static let shared = ImageFileManager()
    
    private init() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.folderPath = documentsURL.appendingPathComponent("images")
        
        try? FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)
        print(documentsURL)
    }
    
    private let fileManager = FileManager.default
    
    private let folderPath: URL
    
    func write(data: Data, fileName: String) throws -> URL {
        let fileURL = folderPath.appending(path: fileName)
        try data.write(to: fileURL)
        
        return fileURL
    }
    
    func getImageURL(fileName: String) -> URL {
        folderPath.appendingPathComponent(fileName)
    }
    
    func getAllImageURL() -> [URL] {
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil) else { return [] }
        return fileURLs.compactMap { url in
            let fileName = url.lastPathComponent
            if fileName.hasPrefix("image_") && fileName.hasSuffix(".jpg") { return url }
            else { return nil }
        }
    }
}
