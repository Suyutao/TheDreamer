//
//  Models.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//
// [V7] 这是我们项目的核心数据模型，基于SwiftData构建。
// [V8] 最终确认此模型作为编码的起点。

import SwiftData
import Foundation

// =======================================================================
// MARK: - 1. 基础定义模型 (The Building Blocks)
// =======================================================================

@Model
final class TestMethod {
    /// [V7] “考法”模型 (e.g., "阅读理解", "力学大题")
    @Attribute(.unique) var name: String
    
    init(name: String) {
        self.name = name
    }
}

@Model
final class QuestionType {
    /// [V7] “题型”模型 (e.g., "选择题", "填空题")
    @Attribute(.unique) var name: String
    
    init(name: String) {
        self.name = name
    }
}

// =======================================================================
// MARK: - 2. 核心配置与枢纽模型 (The Hub)
// =======================================================================

@Model
final class Subject {
    /// [V7] “科目”模型，是数据的枢纽。
    var name: String
    var totalScore: Double
    
    /// [V7] 关系: 一个科目下可以有多个“卷子模板”。
    @Relationship(deleteRule: .cascade)
    var paperTemplates: [PaperTemplate] = []
    
    /// [V6] 计算属性：自动从其关联的模板中，汇总所有出现过的“考法”。
    var availableMethods: [TestMethod] {
        let allMethods = paperTemplates.flatMap { $0.questionTemplates.compactMap { $0.method } }
        return Array(Set(allMethods)).sorted(by: { $0.name < $1.name })
    }
    
    /// [V6] 计算属性：自动汇总所有“题型”。
    var availableTypes: [QuestionType] {
        let allTypes = paperTemplates.flatMap { $0.questionTemplates.compactMap { $0.type } }
        return Array(Set(allTypes)).sorted(by: { $0.name < $1.name })
    }
    
    init(name: String, totalScore: Double) {
        self.name = name
        self.totalScore = totalScore
    }
}

// =======================================================================
// MARK: - 3. 模板与题目模板 (The Blueprints)
// =======================================================================

@Model
final class PaperTemplate {
    /// [V7] “卷子模板”模型，是可复用的卷子结构蓝图。
    var name: String
    var subject: Subject?
    
    @Relationship(deleteRule: .cascade)
    var questionTemplates: [QuestionTemplate] = []
    
    init(name: String, subject: Subject?) {
        self.name = name
        self.subject = subject
    }
}

@Model
final class QuestionTemplate {
    /// [V6] “题目模板”模型，定义了题目的基本属性，但没有“得分”。
    var questionNumber: String
    var points: Double
    var type: QuestionType?
    var method: TestMethod?
    var template: PaperTemplate?
    
    init(questionNumber: String, points: Double, type: QuestionType? = nil, method: TestMethod? = nil, template: PaperTemplate? = nil) {
        self.questionNumber = questionNumber
        self.points = points
        self.type = type
        self.method = method
        self.template = template
    }
}

// =======================================================================
// MARK: - 4. 考试实例与题目实例 (The Instances)
// =======================================================================

@Model
final class Exam {
    /// [V7] “考试”实例模型，代表一次真实发生的、有得分的考试事件。
    var name: String
    var date: Date
    var totalScore: Double
    var subject: Subject?
    
    @Relationship(deleteRule: .cascade)
    var questions: [Question] = []
    
    // ... 其他关联和排名数据 ...
    
    init(name: String, date: Date, totalScore: Double, subject: Subject?) {
        self.name = name
        self.date = date
        self.totalScore = totalScore
        self.subject = subject
    }
}

@Model
final class Question {
    /// [V7] “题目”实例模型，核心数据是“得分(score)”。
    var questionNumber: String
    var points: Double
    var score: Double
    var type: QuestionType?
    var method: TestMethod?
    var exam: Exam?
    
    init(questionNumber: String, points: Double, score: Double, type: QuestionType? = nil, method: TestMethod? = nil, exam: Exam? = nil) {
        self.questionNumber = questionNumber
        self.points = points
        self.score = score
        self.type = type
        self.method = method
        self.exam = exam
    }
}

// =======================================================================
// MARK: - 5. 练习实例与练习组 (Added in V18)
// =======================================================================

@Model
final class PracticeCollection {
    /// [V18] “练习组”模型。用于将同一类型的练习归类。
    /// 例如：“数学午间练”、“英语听力打卡”等。
    var name: String
    
    /// [V18] 关系：一个练习组必须属于一个科目。
    var subject: Subject?
    
    /// [V18] 关系：一个练习组包含多个“练习”实例。
    @Relationship(deleteRule: .cascade)
    var practices: [Practice] = []
    
    init(name: String, subject: Subject?) {
        self.name = name
        self.subject = subject
    }
}

@Model
final class Practice {
    /// [V18] “练习”实例模型。这是一个轻量级的成绩记录。
    var date: Date
    var score: Double
    
    /// [V18] 关系：一个练习必须属于一个练习组。
    var collection: PracticeCollection?
    
    /// [V18] 冗余存储科目信息，用于优化查询。
    /// 在创建时，会自动从其所属的collection中复制subject信息。
    var subject: Subject?
    
    init(date: Date, score: Double, collection: PracticeCollection) {
        self.date = date
        self.score = score
        self.collection = collection
        self.subject = collection.subject
    }
}

