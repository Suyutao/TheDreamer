//
//  DashboardView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// DashboardView 是应用的主页，用于展示用户的学习数据可视化图表。
// 它显示当前是学期的第几周，并提供一个空状态视图作为占位符，
// 未来将在这里展示成绩趋势的可视化图表。

// 常用名词说明：
// View: SwiftUI 中的视图协议，用于定义用户界面。
// struct: Swift 中的结构体，用于定义自定义数据类型。
// body: View 协议中的计算属性，用于定义视图的层次结构。
// NavigationView: SwiftUI 中的导航视图容器，用于管理导航层次结构。
// ScrollView: SwiftUI 中的滚动视图容器，用于容纳可滚动的内容。
// EmptyStateView: 自定义的空状态视图，用于在没有数据时显示提示信息。
// Calendar: Foundation 框架中的类，用于处理日历相关的计算。
// Date: Foundation 框架中的类，用于表示特定的时间点。

import SwiftUI
import SwiftData

/// DashboardView 是应用的主页，用于展示用户的学习数据可视化图表。
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingClearDataAlert = false
    
    /// 计算当前是学期的第几周
    /// - Returns: 当前是学期的第几周
    private var currentWeek: Int {
        // 这里可以放入你之前设定的学期开始日期逻辑
        // 为简单起见，我们先用一个占位符
        return Calendar.current.component(.weekOfYear, from: Date())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 使用我们的通用空状态视图作为占位符
                    EmptyStateView(
                        iconName: "chart.pie.fill",
                        title: "图表正在赶来",
                        message: "在这里，你将看到关于成绩趋势的可视化图表。敬请期待！"
                    )
                    
                    // 清除数据按钮
                    Button(action: {
                        showingClearDataAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("清除所有数据")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 50)
            }
            .navigationTitle("2025年第 \(currentWeek) 周")
            .alert("确认清除数据", isPresented: $showingClearDataAlert) {
                Button("取消", role: .cancel) { }
                Button("清除", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("此操作将删除所有科目、考试、练习等数据，且无法恢复。确定要继续吗？")
            }
        }
     }
     
     // MARK: - 数据清除功能
     
     /// 清除所有数据的函数
     private func clearAllData() {
         do {
             // 删除所有模型数据
             try modelContext.delete(model: Subject.self)
             try modelContext.delete(model: Exam.self)
             try modelContext.delete(model: ExamCollection.self)
             try modelContext.delete(model: Question.self)
             try modelContext.delete(model: QuestionResult.self)
             try modelContext.delete(model: PracticeCollection.self)
             try modelContext.delete(model: Practice.self)
             try modelContext.delete(model: PaperTemplate.self)
             try modelContext.delete(model: QuestionTemplate.self)
             try modelContext.delete(model: PaperStructure.self)
             try modelContext.delete(model: QuestionDefinition.self)
             try modelContext.delete(model: TestMethod.self)
             try modelContext.delete(model: QuestionType.self)
             try modelContext.delete(model: RankData.self)
             
             // 保存更改
             try modelContext.save()
             
             print("[\(Date())] 所有数据已成功清除")
         } catch {
             print("[\(Date())] 清除数据时发生错误: \(error)")
         }
     }
}

#Preview {
    DashboardView()
}
