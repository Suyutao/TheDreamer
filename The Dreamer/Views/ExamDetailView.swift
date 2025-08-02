//
//  ExamDetailView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件定义了考试详细视图界面。
// 目前作为占位符视图，显示考试的基本信息和空状态提示。
// 后续将扩展为完整的考试分析和详细数据展示界面。

// 常用名词解释：
// - View: SwiftUI中的基本界面构建单元
// - struct: 一种数据结构，用于封装相关的属性和功能
// - body: View的必需属性，定义了界面的具体内容
// - NavigationStack: 提供导航栏和层级导航的容器视图
// - ScrollView: 可滚动的容器视图

// 导入构建用户界面所需的SwiftUI框架
import SwiftUI
// 导入用于数据存储和管理的SwiftData框架
import SwiftData

// 定义一个结构体，表示考试详细视图界面
struct ExamDetailView: View {
    // 接收一个考试记录作为参数
    let exam: Exam
    
    // 定义视图的主要内容
    var body: some View {
        // 创建可滚动的视图容器
        ScrollView {
            // 垂直堆叠布局，元素之间间距为20点
            VStack(spacing: 20) {
                // 考试基本信息卡片
                VStack(alignment: .leading, spacing: 12) {
                    // 考试名称
                    Text(exam.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // 科目信息
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundStyle(.blue)
                        Text(exam.subject?.name ?? "未知科目")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 考试日期
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.green)
                        Text(exam.date, style: .date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 总分信息
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(.orange)
                        Text("总分：\(exam.totalScore, specifier: "%.1f")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 占位符空状态视图
                EmptyStateView(
                    iconName: "chart.line.uptrend.xyaxis",
                    title: "详细分析即将到来",
                    message: "这里将显示考试的详细分析数据，包括题目得分情况、知识点分析、历史对比等功能。"
                )
                .padding(.top, 40)
            }
            .padding()
        }
        // 设置导航栏标题为考试名称
        .navigationTitle(exam.name)
        // 使用大标题模式
        .navigationBarTitleDisplayMode(.large)
    }
}

// 预览代码，用于在设计时预览界面效果
#Preview {
    // 创建一个示例考试用于预览
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subject.self, Exam.self, configurations: config)
    let context = container.mainContext
    
    // 创建示例科目
    let subject = Subject(name: "数学", totalScore: 150, orderIndex: 0)
    context.insert(subject)
    
    // 创建示例考试
    let exam = Exam(name: "期中考试", date: Date(), totalScore: 145.5, subject: subject)
    context.insert(exam)
    
    // 保存上下文
    try? context.save()
    
    return NavigationStack {
        ExamDetailView(exam: exam)
    }
    .modelContainer(container)
}