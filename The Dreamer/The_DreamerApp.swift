//
//  The_DreamerApp.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/23/25.
//

// SwiftUI 和 SwiftData 关键术语解释:
//
// 视图 (View):
//   - SwiftUI 中的基本构建块，用于描述用户界面
//   - 每个视图都定义了如何根据其状态显示界面
//   - 视图是结构体，遵循 View 协议
//
// 模型 (Model):
//   - 在 SwiftData 中，模型是遵循 @Model 宏的 Swift 类或结构体
//   - 模型定义了应用的数据结构和关系
//   - SwiftData 会自动处理模型的持久化存储
//
// Schema:
//   - SwiftData 中用于定义应用所有数据模型的集合
//   - 在应用启动时创建，告诉 SwiftData 需要管理哪些数据类型
//   - 所有需要持久化的模型都必须在 schema 中注册
//
// 容器 (ModelContainer):
//   - SwiftData 中用于管理数据模型的运行时环境
//   - 包含 schema 定义的所有模型类型
//   - 处理数据的加载、保存和查询操作
//   - 可以配置为内存存储（用于测试）或磁盘存储（用于持久化）

import SwiftUI
import SwiftData

// 这是应用的主结构体，它遵循 App 协议，表示这是一个 SwiftUI 应用
@main
struct TheDreamerApp: App {
    // 这里定义了一个名为 sharedModelContainer 的变量，它是一个 ModelContainer 类型
    // ModelContainer 是 SwiftData 用来管理数据模型的容器
    var sharedModelContainer: ModelContainer = {
        // 创建一个 schema，它定义了应用中所有需要持久化的数据模型
        let schema = Schema([
            Subject.self,
            PaperTemplate.self,
            Exam.self,  // 添加 Exam 模型
            Practice.self,  // 添加 Practice 模型
            PracticeCollection.self,  // 添加 PracticeCollection 模型
            Question.self,  // 添加 Question 模型
            QuestionTemplate.self,  // 添加 QuestionTemplate 模型
            TestMethod.self,  // 添加 TestMethod 模型
            QuestionType.self  // 添加 QuestionType 模型
        ])
        // 创建一个模型配置，指定 schema 并设置数据不是仅存储在内存中（即会持久化到磁盘）
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        // 尝试创建 ModelContainer，如果失败则应用会崩溃并显示错误信息
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // 这是应用的主体部分，定义了应用的用户界面
    var body: some Scene {
        WindowGroup {
            // 这里是应用的根视图
            MainTabView()
        }
        // 将我们创建的模型容器附加到场景中，这样应用的所有部分都可以访问这些数据模型
        .modelContainer(sharedModelContainer)
    }
}
