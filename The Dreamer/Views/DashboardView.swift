//
//  DashboardView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// DashboardView 是应用的摘要页，用于展示用户的学习数据可视化图表。
// 它显示当前是学期的第几周，并展示多个科目的成绩折线图卡片。

import SwiftUI
import SwiftData

/// DashboardView 是应用的摘要页，用于展示用户的学习数据可视化图表。
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 查询所有科目，按orderIndex排序
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    // 查询所有考试，按日期倒序
    @Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]
    
    @State private var showingSettingsSheet = false
    
    /// 计算当前是学期的第几周
    private var currentWeek: Int {
        Calendar.current.component(.weekOfYear, from: Date())
    }
    
    /// 获取指定科目的最新考试记录
    private func getLatestExam(for subject: Subject) -> Exam? {
        subject.exams.sorted { $0.date > $1.date }.first
    }
    
    /// 获取指定科目的SF Symbol图标
    private func getSubjectIcon(for subject: Subject) -> String {
        // 根据科目名称返回对应的SF Symbol
        switch subject.name {
        case let name where name.contains("语文"):
            return "text.book.closed"
        case let name where name.contains("数学"):
            return "function"
        case let name where name.contains("英语"):
            return "textformat.abc"
        case let name where name.contains("物理"):
            return "atom"
        case let name where name.contains("化学"):
            return "flask"
        case let name where name.contains("生物"):
            return "leaf"
        case let name where name.contains("历史"):
            return "clock"
        case let name where name.contains("地理"):
            return "globe.asia.australia"
        case let name where name.contains("政治"):
            return "building.columns"
        default:
            return "book"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 摘要部分
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("置顶")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("编辑") {
                                // TODO: 实现编辑功能
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        // 科目成绩卡片
                        ForEach(subjects.prefix(4)) { subject in
                            if let latestExam = getLatestExam(for: subject) {
                                SubjectScoreLineChart(
                                    subjectName: subject.name,
                                    score: latestExam.score,
                                    date: latestExam.date,
                                    iconSystemName: getSubjectIcon(for: subject)
                                )
                                .padding(.horizontal)
                            }
                        }
                        
                        // 如果没有数据，显示空状态
                        if subjects.isEmpty || subjects.allSatisfy({ getLatestExam(for: $0) == nil }) {
                            EmptyStateView(
                                iconName: "chart.bar.fill",
                                title: "暂无成绩数据",
                                message: "添加一些考试记录后，这里将显示你的成绩摘要"
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 20)
            }
            .navigationTitle("第 \(currentWeek) 周摘要")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettingsSheet = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
                    .environment(\.modelContext, modelContext)
            }
        }
    }
}

#Preview {
    DashboardView()
}
