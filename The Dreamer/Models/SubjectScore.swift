//
//  SubjectScore.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/24/25.
//

import Foundation
import SwiftData

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
        isUnited: Bool = false,
        subject: String,
        score: Double,
        fullScore: Double = 150,
        isCurved: Bool = false,
        isElective: Bool = true,
        classRank: Int? = nil,
        classTotal: Int? = nil,
        gradeRank: Int? = nil,
        gradeTotal: Int? = nil,
        scoreRatio: Double = 0,
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
