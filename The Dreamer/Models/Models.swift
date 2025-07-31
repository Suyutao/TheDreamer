//
//  Models.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//
// [V7] 这是我们项目的核心数据模型，基于SwiftData构建。
// [V8] 最终确认此模型作为编码的起点。

// SwiftUI 和 SwiftData 关键术语解释:
//
// 模型 (Model):
//   - 在 SwiftData 中，模型是遵循 @Model 宏的 Swift 类或结构体
//   - 模型定义了应用的数据结构和关系
//   - SwiftData 会自动处理模型的持久化存储
//   - 每个模型实例代表数据库中的一条记录
//
// 属性 (Attribute):
//   - 模型中的基本数据字段
//   - 可以指定属性的特性，如唯一性 (.unique)
//   - SwiftData 会自动为这些属性生成存储和查询代码
//
// 关系 (Relationship):
//   - 模型之间的关联关系
//   - 可以是一对一、一对多或多对多关系
//   - deleteRule 参数定义了当父对象被删除时子对象的行为
//   - .cascade 表示删除父对象时也删除所有相关联的子对象
//
// 计算属性:
//   - 基于模型其他属性动态计算得出的属性
//   - 不会直接存储在数据库中
//   - 每次访问时都会重新计算

import SwiftData
import Foundation

// MARK: - 基础定义模型 (The Building Blocks)

@Model
final class TestMethod {
    /// [V7] "考法"模型 (e.g., "阅读理解", "力学大题")
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

// MARK: - 核心配置与枢纽模型 (The Hub)

@Model
final class Subject {
    /// [V7] “科目”模型，是数据的枢纽。
    var name: String
    var totalScore: Double
    
    // [V22] 新增：用于手动排序的索引。
    // [V22] 数字越小，排在越前面。
    @Attribute(.unique) var orderIndex: Int
    
    /// [V7] 关系: 一个科目下可以有多个“卷子模板”。
    @Relationship(deleteRule: .cascade)
    var paperTemplates: [PaperTemplate] = []
    
    /// [V6] 计算属性：自动从其关联的模板中，汇总所有出现过的"考法"。
    var availableMethods: [TestMethod] {
        let allMethods = paperTemplates.flatMap { $0.questionTemplates.compactMap { $0.method } }
        return Array(Set(allMethods)).sorted(by: { $0.name < $1.name })
    }
    
    /// [V6] 计算属性：自动汇总所有"题型"。
    var availableTypes: [QuestionType] {
        let allTypes = paperTemplates.flatMap { $0.questionTemplates.compactMap { $0.type } }
        return Array(Set(allTypes)).sorted(by: { $0.name < $1.name })
    }
    
    init(name: String, totalScore: Double, orderIndex: Int = 0) {
            self.name = name
            self.totalScore = totalScore
            self.orderIndex = orderIndex
    }
}

// MARK: - 模板与题目模板 (The Blueprints)

@Model
final class PaperTemplate {
    /// [V7] "卷子模板"模型，是可复用的卷子结构蓝图。
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
    /// [V6] "题目模板"模型，定义了题目的基本属性，但没有"得分"。
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

// MARK: - 考试实例与题目实例 (The Instances)

@Model
final class Exam {
    /// [V7] "考试"实例模型，代表一次真实发生的、有得分的考试事件。
    var name: String
    var date: Date
    var totalScore: Double
    var subject: Subject?
    
    @Relationship(deleteRule: .cascade)
    var questions: [Question] = []
    
    // 关系
    var subject: Subject?
    var collection: ExamCollection? // 可选，属于某个联考
    
    // 新增：与卷子结构的关联
    var paperStructure: PaperStructure? // 记录本次考试使用的卷子结构
    
    // 新增：详细的题目得分记录
    @Relationship(deleteRule: .cascade) // 如果删除了这次考试，其下的题目得分记录也一并删除
    var questionResults: [QuestionResult] = []
    
    var classRank: RankData?
    var gradeRank: RankData?
    
    init(name: String, date: Date, totalScore: Double, subject: Subject?) {
        self.name = name
        self.date = date
        self.totalScore = totalScore
        self.subject = subject
    }
}

@Model
final class Question {
    /// [V7] "题目"实例模型，核心数据是"得分(score)"。
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

// MARK: - 练习实例与练习组 (Added in V18)

@Model
final class PracticeCollection {
    /// [V18] "练习组"模型。用于将同一类型的练习归类。
    /// 例如："数学午间练"、"英语听力打卡"等。
    var name: String
    
    /// [V18] 关系：一个练习组必须属于一个科目。
    var subject: Subject?
    
    /// [V18] 关系：一个练习组包含多个"练习"实例。
    @Relationship(deleteRule: .cascade)
    var practices: [Practice] = []
    
    init(name: String, subject: Subject?) {
        self.name = name
        self.subject = subject
    }
}

@Model
final class Practice {
    /// [V18] "练习"实例模型。这是一个轻量级的成绩记录。
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

