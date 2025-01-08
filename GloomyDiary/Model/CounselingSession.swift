//
//  CounselingSession.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import Foundation
import SwiftData

@Model
final class CounselingSession {
    @Attribute(.unique) var id: UUID
    var counselorIdentifier: String
    var title: String
    var query: String
    var response: String
    var createdAt: Date
    var weatherIdentifier: String
    var emojiIdentifier: String
    @Attribute(.transformable(by: ArrayTransformer.name.rawValue)) var images: [String]

    init(id: UUID, counselorIdentifier: String, title: String, query: String, response: String, createdAt: Date, weatherIdentifier: String, emojiIdentifier: String, images: [String] = []) {
        self.id = id
        self.counselorIdentifier = counselorIdentifier
        self.title = title
        self.query = query
        self.response = response
        self.createdAt = createdAt
        self.weatherIdentifier = weatherIdentifier
        self.emojiIdentifier = emojiIdentifier
        self.images = images
    }
}

extension CounselingSession {
    convenience init(dto: CounselingSessionDTO) {
        self.init(id: dto.id,
                  counselorIdentifier: dto.counselor.identifier,
                  title: dto.title,
                  query: dto.query,
                  response: dto.response,
                  createdAt: dto.createdAt,
                  weatherIdentifier: dto.weather.identifier,
                  emojiIdentifier: dto.emoji.identifier,
                  images: dto.urls.map { $0.lastPathComponent })
    }
    
    func toDTO() -> CounselingSessionDTO? {
        guard let counselor = CharacterDTO(identifier: self.counselorIdentifier),
              let weather = WeatherDTO(identifier: self.weatherIdentifier),
              let emoji = EmojiDTO(identifier: self.emojiIdentifier) else { return nil }
        
        return CounselingSessionDTO(id: self.id,
                                    counselor: counselor,
                                    title: self.title,
                                    query: self.query,
                                    response: self.response,
                                    createdAt: self.createdAt,
                                    weather: weather,
                                    emoji: emoji,
                                    urls: images.map { ImageFileManager.shared.getImageURL(fileName: $0) })
    }
}

@objc(ArrayTransformer)
class ArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else {
            return nil
        }
        let nsArray = array as NSArray
        return try? NSKeyedArchiver.archivedData(withRootObject: nsArray, requiringSecureCoding: true)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        guard let nsArrayAny = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self], from: data) else { return nil }
        guard let strings = nsArrayAny as? [String] else { return nil }
        return strings
    }
}

extension ArrayTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: ArrayTransformer.self))
    
    public static func register() {
        let transformer = ArrayTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
