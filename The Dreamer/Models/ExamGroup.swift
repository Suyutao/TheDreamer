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
    var name: String // ExamName.rawValue
    var customName: String?
    var date: Date
    var examType: String // ExamType.rawValue
    var scoreCategory: String // ScoreCategory.rawValue
    var customCategoryName: String?
    var remark: String?

    init(id: UUID = .init(), name: String, customName: String? = nil, date: Date, examType: String, scoreCategory: String, customCategoryName: String? = nil, remark: String? = nil) {
        self.id = id
        self.name = name
        self.customName = customName
        self.date = date
        self.examType = examType
        self.scoreCategory = scoreCategory
        self.customCategoryName = customCategoryName
        self.remark = remark
    }
}
