//
//  MainTabView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// MainTabView 是应用的主标签页视图，它包含两个标签页：
// 1. 仪表板 (DashboardView)
// 2. 分析 (AnalysisView)
// 用户可以通过点击底部的标签页图标来切换不同的视图。

// 常用名词说明：
// View: SwiftUI 中的视图协议，用于定义用户界面。
// struct: Swift 中的结构体，用于定义自定义数据类型。
// body: View 协议中的计算属性，用于定义视图的层次结构。
// TabView: SwiftUI 中的标签页视图容器，用于管理多个标签页。
// DashboardView: 应用的主页，用于展示用户的学习数据可视化图表。
// AnalysisView: 用于展示和分析用户考试和练习数据的视图。
// Label: SwiftUI 中的视图，用于显示文本和图标。

import SwiftUI
import SwiftData

/// MainTabView 是应用的主标签页视图，它包含两个标签页：仪表板和分析。
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("仪表板", systemImage: "rectangle.3.group")
                }
            
            AnalysisView()
                .tabItem {
                    Label("分析", systemImage: "chart.bar.xaxis")
                }
        }
        .onAppear {
            performDataIntegrityCheck()
        }
    }
    
    // MARK: - 数据完整性检查
    
    /// 执行数据完整性检查，清理所有异常的数据引用
    private func performDataIntegrityCheck() {
        // 检查是否需要执行数据完整性检查
        // 这是一个临时功能，用于清理在修复关系约束之前产生的异常数据
        let shouldPerformCheck = UserDefaults.standard.bool(forKey: "ShouldPerformDataIntegrityCheck")
        
        // 如果是首次启动或者用户明确要求检查，则执行
        if !UserDefaults.standard.bool(forKey: "HasPerformedInitialDataCheck") || shouldPerformCheck {
            print("[\(Date())] 开始执行数据完整性检查...")
            
            do {
                // 1. 检查并清理 PaperStructure 中的无效 Subject 引用
                cleanInvalidPaperStructures()
                
                // 2. 检查并清理 PaperTemplate 中的无效 Subject 引用
                cleanInvalidPaperTemplates()
                
                // 3. 检查并清理 Exam 中的无效 Subject 引用
                cleanInvalidExams()
                
                // 4. 检查并清理 PracticeCollection 中的无效 Subject 引用
                cleanInvalidPracticeCollections()
                
                // 5. 检查并清理 Practice 中的无效 Subject 引用
                cleanInvalidPractices()
                
                // 保存更改
                try modelContext.save()
                print("[\(Date())] 数据完整性检查完成，所有异常数据已清理")
                
                // 标记已完成首次检查
                UserDefaults.standard.set(true, forKey: "HasPerformedInitialDataCheck")
                // 重置手动检查标志
                UserDefaults.standard.set(false, forKey: "ShouldPerformDataIntegrityCheck")
                
            } catch {
                print("[\(Date())] 数据完整性检查失败: \(error.localizedDescription)")
            }
        } else {
            print("[\(Date())] 跳过数据完整性检查（已完成或未启用）")
        }
    }
    
    /// 清理 PaperStructure 中的无效 Subject 引用
    private func cleanInvalidPaperStructures() {
        let descriptor = FetchDescriptor<PaperStructure>(predicate: #Predicate { $0.subject == nil })
        do {
            let invalids = try modelContext.fetch(descriptor)
            invalids.forEach { modelContext.delete($0) }
            if !invalids.isEmpty {
                print("[\(Date())] 清理了 \(invalids.count) 个无效的 PaperStructure")
            }
        } catch {
            print("[\(Date())] 清理 PaperStructure 失败: \(error.localizedDescription)")
        }
    }

    
    /// 清理 PaperTemplate 中的无效 Subject 引用
    private func cleanInvalidPaperTemplates() {
        let descriptor = FetchDescriptor<PaperTemplate>(predicate: #Predicate { $0.subject == nil })
        do {
            let invalids = try modelContext.fetch(descriptor)
            invalids.forEach { modelContext.delete($0) }
            if !invalids.isEmpty {
                print("[\(Date())] 清理了 \(invalids.count) 个无效的 PaperTemplate")
            }
        } catch {
            print("[\(Date())] 清理 PaperTemplate 失败: \(error.localizedDescription)")
        }
    }

    
    /// 清理 Exam 中的无效 Subject 引用
    private func cleanInvalidExams() {
        // 使用谓词直接过滤 subject == nil，避免解引用导致崩溃
        let descriptor = FetchDescriptor<Exam>(predicate: #Predicate { $0.subject == nil })
        do {
            let invalidExams = try modelContext.fetch(descriptor)
            invalidExams.forEach { modelContext.delete($0) }
            if !invalidExams.isEmpty {
                print("[\(Date())] 清理了 \(invalidExams.count) 个无效的 Exam")
            }
        } catch {
            print("[\(Date())] 清理 Exam 失败: \(error.localizedDescription)")
        }
    }

    
    /// 清理 PracticeCollection 中的无效 Subject 引用
    private func cleanInvalidPracticeCollections() {
        let descriptor = FetchDescriptor<PracticeCollection>(predicate: #Predicate { $0.subject == nil })
        do {
            let invalids = try modelContext.fetch(descriptor)
            invalids.forEach { modelContext.delete($0) }
            if !invalids.isEmpty {
                print("[\(Date())] 清理了 \(invalids.count) 个无效的 PracticeCollection")
            }
        } catch {
            print("[\(Date())] 清理 PracticeCollection 失败: \(error.localizedDescription)")
        }
    }

    
    /// 清理 Practice 中的无效 Subject 引用
    private func cleanInvalidPractices() {
        let descriptor = FetchDescriptor<Practice>(predicate: #Predicate { $0.subject == nil })
        do {
            let invalids = try modelContext.fetch(descriptor)
            invalids.forEach { modelContext.delete($0) }
            if !invalids.isEmpty {
                print("[\(Date())] 清理了 \(invalids.count) 个无效的 Practice")
            }
        } catch {
            print("[\(Date())] 清理 Practice 失败: \(error.localizedDescription)")
        }
    }

}

#Preview {
    MainTabView()
}
