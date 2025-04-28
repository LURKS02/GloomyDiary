//
//  SwiftDataService.swift
//  GloomyDiary
//
//  Created by 디해 on 12/21/24.
//

import Foundation
import SwiftData

@ModelActor
final actor SwiftDataService<T: PersistentModel> {
    func fetch(descriptor: FetchDescriptor<T>? = nil) throws -> [T] {
        return try modelContext.fetch(descriptor ?? FetchDescriptor<T>())
    }
    
    func create(_ object: T) {
        modelContext.insert(object)
    }
    
    func delete(_ object: T) {
        modelContext.delete(object)
    }
    
    func save() throws {
        try modelContext.save()
    }
}
