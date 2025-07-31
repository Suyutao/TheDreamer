//
//  The_DreamerApp.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/23/25.
//

import SwiftUI
import SwiftData

@main
struct TheDreamerApp: App {
    // 添加模型容器配置，用于SwiftData数据持久化
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Subject.self,
            PaperTemplate.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        // 将模型容器添加到场景中
        .modelContainer(sharedModelContainer)
    }
}
