//
//  UserProfile.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/24/25.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var region: String
    var schoolType: String
    var examMode: String
    var selectedSubjects: [String] // SwiftData不支持直接存枚举数组，建议用String
    var semesterStartDate: Date
    // 新增onboarding相关属性
    var classSize: Int?
    var gradeSize: Int?
    var targetCollege: String?
    var targetScore: Double?
    var lastModifiedDate: Date

    init(id: UUID = .init(), region: String, schoolType: String, examMode: String, selectedSubjects: [String], semesterStartDate: Date, classSize: Int? = nil, gradeSize: Int? = nil, targetCollege: String? = nil, targetScore: Double? = nil, lastModifiedDate: Date = Date()) {
        self.id = id
        self.region = region
        self.schoolType = schoolType
        self.examMode = examMode
        self.selectedSubjects = selectedSubjects
        self.semesterStartDate = semesterStartDate
        self.classSize = classSize
        self.gradeSize = gradeSize
        self.targetCollege = targetCollege
        self.targetScore = targetScore
        self.lastModifiedDate = lastModifiedDate
    }
}
