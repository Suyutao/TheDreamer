//
//  Item.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/23/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var region: String
    var schoolType: String
    var examMode: String
    var selectedSubjects: [String] // SwiftData不支持直接存枚举数组，建议用String
    var semesterStartDate: Date

    init(id: UUID = .init(), region: String, schoolType: String, examMode: String, selectedSubjects: [String], semesterStartDate: Date) {
        self.id = id
        self.region = region
        self.schoolType = schoolType
        self.examMode = examMode
        self.selectedSubjects = selectedSubjects
        self.semesterStartDate = semesterStartDate
    }
}

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

@Model
final class SubjectScore {
    @Attribute(.unique) var id: UUID
    var groupID: UUID?
    var isUnited: Bool
    var subject: String // Subject.rawValue
    var score: Double
    var fullScore: Double
    var isCurved: Bool
    var isElective: Bool
    var classRank: Int?
    var classTotal: Int?
    var gradeRank: Int?
    var gradeTotal: Int?
    var scoreRatio: Double
    var classRankRatio: Double?
    var gradeRankRatio: Double?
    var classAverage: Double?
    var classMedian: Double?
    var gradeAverage: Double?
    var gradeMedian: Double?
    var remark: String?

    init(
        id: UUID = .init(),
        groupID: UUID? = nil,
        isUnited: Bool,
        subject: String,
        score: Double,
        fullScore: Double,
        isCurved: Bool,
        isElective: Bool,
        classRank: Int? = nil,
        classTotal: Int? = nil,
        gradeRank: Int? = nil,
        gradeTotal: Int? = nil,
        scoreRatio: Double,
        classRankRatio: Double? = nil,
        gradeRankRatio: Double? = nil,
        classAverage: Double? = nil,
        classMedian: Double? = nil,
        gradeAverage: Double? = nil,
        gradeMedian: Double? = nil,
        remark: String? = nil
    ) {
        self.id = id
        self.groupID = groupID
        self.isUnited = isUnited
        self.subject = subject
        self.score = score
        self.fullScore = fullScore
        self.isCurved = isCurved
        self.isElective = isElective
        self.classRank = classRank
        self.classTotal = classTotal
        self.gradeRank = gradeRank
        self.gradeTotal = gradeTotal
        self.scoreRatio = scoreRatio
        self.classRankRatio = classRankRatio
        self.gradeRankRatio = gradeRankRatio
        self.classAverage = classAverage
        self.classMedian = classMedian
        self.gradeAverage = gradeAverage
        self.gradeMedian = gradeMedian
        self.remark = remark
    }
}
