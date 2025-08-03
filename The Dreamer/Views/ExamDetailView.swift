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
// 导入图表框架用于绘制折线图
import Charts
// 导入Foundation框架用于基础数据类型和功能
import Foundation

// 定义一个结构体，表示考试详细视图界面
struct ExamDetailView: View {
    // 接收一个考试记录作为参数
    let exam: Exam
    
    // 查询同一科目的所有考试记录，用于绘制折线图
    @Query private var allExams: [Exam]
    
    // MARK: - 导航状态变量
    // 控制是否显示编辑视图
    @State private var showingEditView = false
    
    // 初始化方法，设置查询条件
    init(exam: Exam) {
        self.exam = exam
        // 查询同一科目的所有考试，按日期排序
        // 使用 subject 的 id 而不是 name 来避免访问失效对象
        if let subject = exam.subject {
            let subjectId = subject.persistentModelID
            self._allExams = Query(
                filter: #Predicate<Exam> { examItem in
                    examItem.subject?.persistentModelID == subjectId
                },
                sort: \Exam.date
            )
        } else {
            // 如果没有关联科目，查询所有没有科目的考试
            self._allExams = Query(
                filter: #Predicate<Exam> { examItem in
                    examItem.subject == nil
                },
                sort: \Exam.date
            )
        }
    }
    
    // MARK: - 计算属性
    
    /// 安全地获取科目名称，避免访问失效对象
    private var safeSubjectName: String {
        if let subject = exam.subject {
            return subject.name
        } else {
            return "未知科目"
        }
    }
    
    /// 生成折线图数据点
    private var chartDataPoints: [ChartDataPoint] {
        allExams.map { examItem in
            // 安全地获取科目名称，避免访问失效对象
            let subjectName: String
            if let subject = examItem.subject {
                subjectName = subject.name
            } else {
                subjectName = "未知科目"
            }
            
            return ChartDataPoint(
                date: examItem.date,
                score: examItem.totalScore,
                totalScore: examItem.subject?.totalScore ?? 100,
                examName: examItem.name,
                subject: subjectName,
                type: .myScore
            )
        }
    }
    
    // 定义视图的主要内容
    var body: some View {
        // 创建可滚动的视图容器
        ScrollView {
            // 垂直堆叠布局，元素之间间距为20点
            VStack(spacing: 20) {
                // MARK: - 基本信息卡片
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.blue)
                        Text("考试名称")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(exam.name)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(.green)
                        Text("科目")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(safeSubjectName)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                        Text("考试日期")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(exam.date, style: .date)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.purple)
                        Text("总分")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(exam.totalScore))")
                            .fontWeight(.medium)
                    }
                }
                .dashboardPanel("考试信息")
                
                // MARK: - 折线图区域
                Group {
                    if chartDataPoints.count >= 2 {
                        LineChartView(
                            dataPoints: chartDataPoints,
                            selectedSubject: safeSubjectName,
                            visibleLines: [.myScore],
                            chartStyle: .smooth,
                            showYAxisAsPercentage: false
                        )
                    } else {
                        EmptyStateView(
                            iconName: "chart.line.uptrend.xyaxis",
                            title: "成绩趋势",
                            message: "需要至少2次考试记录才能显示趋势图"
                        )
                        .frame(height: 300)
                    }
                }
                .dashboardPanel("成绩趋势")
            }
            .padding(.horizontal, 16)
        }
        // 设置导航栏标题为考试名称
        .navigationTitle(exam.name)
        // 使用大标题模式
        .navigationBarTitleDisplayMode(.large)
        // 添加工具栏按钮
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑", systemImage: "pencil") {
                    showingEditView = true
                }
            }
        }
        // 显示编辑视图
        .sheet(isPresented: $showingEditView) {
            NavigationView {
                AddDataView(dataType: Binding.constant(.exam), examToEdit: exam)
            }
        }
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
    
    // 创建多个示例考试来展示折线图
    let exams = [
        Exam(name: "第一次月考", date: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(), totalScore: 135.0, subject: subject),
        Exam(name: "第二次月考", date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(), totalScore: 142.5, subject: subject),
        Exam(name: "期中考试", date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), totalScore: 145.5, subject: subject),
        Exam(name: "第三次月考", date: Date(), totalScore: 148.0, subject: subject)
    ]
    
    exams.forEach { context.insert($0) }
    
    // 保存上下文
    try? context.save()
    
    return NavigationStack {
        ExamDetailView(exam: exams.last!)
    }
    .modelContainer(container)
}