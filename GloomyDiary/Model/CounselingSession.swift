//
//  CounselingSession.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import Foundation
import SwiftData

typealias CounselingSession = SessionSchemaV2.CounselingSession

enum SessionSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [CounselingSession.self]
    }
    
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
        
        init(id: UUID, counselorIdentifier: String, title: String, query: String, response: String, createdAt: Date, weatherIdentifier: String, emojiIdentifier: String) {
            self.id = id
            self.counselorIdentifier = counselorIdentifier
            self.title = title
            self.query = query
            self.response = response
            self.createdAt = createdAt
            self.weatherIdentifier = weatherIdentifier
            self.emojiIdentifier = emojiIdentifier
        }
    }
}
 
enum SessionSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 0)
    
    static var models: [any PersistentModel.Type] {
        [CounselingSession.self]
    }
    
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
        @Attribute(.transformable(by: ArrayTransformer.name.rawValue)) var images: [String] = []
        
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
}

enum SessionMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SessionSchemaV1.self, SessionSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SessionSchemaV1.self,
        toVersion: SessionSchemaV2.self,
        willMigrate: { context in
            let sessions = try context.fetch(FetchDescriptor<SessionSchemaV1.CounselingSession>())
            for session in sessions {
                let newSession = SessionSchemaV2.CounselingSession(
                    id: session.id,
                    counselorIdentifier: session.counselorIdentifier,
                    title: session.title,
                    query: session.query,
                    response: session.response,
                    createdAt: session.createdAt,
                    weatherIdentifier: session.weatherIdentifier,
                    emojiIdentifier: session.emojiIdentifier,
                    images: [])
                context.insert(newSession)
                context.delete(session)
            }
            
            try context.save()
        },
        didMigrate: nil)
}

extension CounselingSession {
    convenience init(session: Session) {
        self.init(id: session.id,
                  counselorIdentifier: session.counselor.identifier,
                  title: session.title,
                  query: session.query,
                  response: session.response,
                  createdAt: session.createdAt,
                  weatherIdentifier: session.weather.identifier,
                  emojiIdentifier: session.emoji.identifier,
                  images: session.imageIDs.map { $0.uuidString })
    }
    
    func toDomain() -> Session? {
        guard let counselor = CounselingCharacter(identifier: self.counselorIdentifier),
              let weather = Weather(identifier: self.weatherIdentifier),
              let emoji = Emoji(identifier: self.emojiIdentifier) else { return nil }
        
        return Session(
            id: self.id,
            counselor: counselor,
            title: self.title,
            query: self.query,
            response: self.response,
            createdAt: self.createdAt,
            weather: weather,
            emoji: emoji,
            imageIDs: images.compactMap { UUID(uuidString: $0) })
    }
}
