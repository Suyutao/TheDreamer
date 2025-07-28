//
//  ExamGroup.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/24/25.
//

import Foundation
import SwiftData

@Model
final class ExamGroup {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: ExamType // 大型考试/小型考试
    var date: Date
    var groupId: String? // 用于关联同一大型考试下的小型考试
    var subjectScores: [SubjectScore]?
    
    init(id: UUID = .init(), name: String, type: ExamType, date: Date, groupId: String? = nil, subjectScores: [SubjectScore]? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.date = date
        self.groupId = groupId
        self.subjectScores = subjectScores
    }
}

enum ExamType: String, Codable {
    case large // 大型考试
    case small // 小型考试
}
