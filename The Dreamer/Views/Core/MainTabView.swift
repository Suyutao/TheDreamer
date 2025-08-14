//
//  MainTabView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// MainTabView 是应用的主标签页视图，它包含两个标签页：
// 1. 摘要 (DashboardView)
// 2. 数据库 (AnalysisView)
// 用户可以通过点击底部的标签页图标来切换不同的视图。

// 常用名词说明：
// View: SwiftUI 中的视图协议，用于定义用户界面。
// struct: Swift 中的结构体，用于定义自定义数据类型。
// body: View 协议中的计算属性，用于定义视图的层次结构。
// TabView: SwiftUI 中的标签页视图容器，用于管理多个标签页。
// DashboardView: 应用的摘要页，用于展示用户的学习数据可视化图表。
// AnalysisView: 数据库视图，用于展示和管理所有数据。
// Label: SwiftUI 中的视图，用于显示文本和图标。

import SwiftUI
import SwiftData

/// MainTabView 是应用的主标签页视图，它包含两个标签页：摘要和数据库。
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Database()
                .tabItem {
                    Label("摘要", systemImage: "chart.bar.doc.horizontal")
                }
            
            AnalysisView()
                .tabItem {
                    Label("数据库", systemImage: "cylinder.split.1x2")
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
                
                // 6. 回填迁移后新增的可选时间戳字段，保障后续逻辑稳定
                backfillMissingTimestamps()
                
                // 保存更改
                try modelContext.save()
                print("[\(Date())] 数据完整性检查完成，所有异常数据已清理并完成时间戳回填")
                
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

    
    /// 回填迁移后新增的可选时间戳字段，避免 nil 影响后续逻辑
    private func backfillMissingTimestamps() {
        let now = Date()
        do {
            // Subject: 用首个考试日期或当前时间
            let subjects = try modelContext.fetch(FetchDescriptor<Subject>())
            for s in subjects {
                if s.createdAt == nil {
                    let firstExamDate = s.exams.sorted(by: { $0.date < $1.date }).first?.date
                    s.createdAt = firstExamDate ?? now
                }
                if s.updatedAt == nil { s.updatedAt = s.createdAt ?? now }
            }
            
            // Exam: 用自身日期
            let exams = try modelContext.fetch(FetchDescriptor<Exam>())
            for e in exams {
                if e.createdAt == nil { e.createdAt = e.date }
                if e.updatedAt == nil { e.updatedAt = e.createdAt ?? now }
            }
            
            // PracticeCollection: 用首个练习日期或当前时间
            let collections = try modelContext.fetch(FetchDescriptor<PracticeCollection>())
            for c in collections {
                if c.createdAt == nil {
                    let firstPracticeDate = c.practices.sorted(by: { $0.date < $1.date }).first?.date
                    c.createdAt = firstPracticeDate ?? now
                }
                if c.updatedAt == nil { c.updatedAt = c.createdAt ?? now }
            }
            
            // Practice: 用自身日期
            let practices = try modelContext.fetch(FetchDescriptor<Practice>())
            for p in practices {
                if p.createdAt == nil { p.createdAt = p.date }
                if p.updatedAt == nil { p.updatedAt = p.createdAt ?? now }
            }
        } catch {
            print("[\(Date())] 时间戳回填失败: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainTabView()
}
