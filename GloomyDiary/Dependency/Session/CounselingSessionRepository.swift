//
//  CounselingSessionRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 10/18/24.
//

import Foundation

protocol CounselingSessionRepository {
    func fetch() async throws -> [Session]
    func fetch(pageNumber: Int, pageSize: Int) async throws -> [Session]
    func create(_ session: Session) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> Session?
    func save() async throws
    
    func deleteAll() async throws
}
