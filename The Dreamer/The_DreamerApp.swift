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
    private let sharedModelContainer: ModelContainer
    private let modelContainerError: String?

    init() {
        do {
            sharedModelContainer = try TheDreamerModelContainer.make()
            modelContainerError = nil
        } catch {
            modelContainerError = String(describing: error)
            do {
                sharedModelContainer = try TheDreamerModelContainer.make(isStoredInMemoryOnly: true)
            } catch {
                fatalError("Could not create temporary ModelContainer: \(error)")
            }
        }
    }

    // 这是应用的主体部分，定义了应用的用户界面
    var body: some Scene {
        WindowGroup {
            if let modelContainerError {
                ModelContainerErrorView(errorDescription: modelContainerError)
            } else {
                ContentView()
            }
        }
        // 将我们创建的模型容器附加到场景中，这样应用的所有部分都可以访问这些数据模型
        .modelContainer(sharedModelContainer)

        WindowGroup("课程表", id: "timetable-workspace", for: PersistentIdentifier.self) { timetableID in
            TimetableWindowView(timetableID: timetableID.wrappedValue)
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct ModelContainerErrorView: View {
    let errorDescription: String

    var body: some View {
        ContentUnavailableView {
            Label("无法打开本地数据", systemImage: "externaldrive.badge.exclamationmark")
        } description: {
            Text("旧数据库没有被删除。请复制下方错误信息后关闭应用。")
        } actions: {
            Text(errorDescription)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: 600)
        }
        .padding()
    }
}

// MARK: - 内容视图

/// 应用的主内容视图，负责决定显示OnBoarding还是主界面
struct ContentView: View {
    // 使用 @AppStorage 检测是否已完成引导
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                // 已完成引导，显示主界面
                MainTabView()
            } else {
                // 首次启动，显示引导流程
                OnBoardingView()
            }
        }
    }
}
