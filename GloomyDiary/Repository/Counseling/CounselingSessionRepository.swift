//
//  CounselingSessionRepository.swift
//  GloomyDiary
//
//  Created by 디해 on 10/18/24.
//

import Foundation

protocol CounselingSessionRepository {
    func fetch() async throws -> [CounselingSessionDTO]
    func create(_ sessionDTO: CounselingSessionDTO) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> CounselingSessionDTO?
}
