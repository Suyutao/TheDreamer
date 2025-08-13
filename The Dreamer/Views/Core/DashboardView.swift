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
                LazyVStack(spacing: 10) {
                    // 摘要部分
                    VStack(alignment: .leading, spacing: 10) {
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
                        .padding(.top, 10)
                        
                        // 科目成绩卡片（Figma卡片预览用）
                        ForEach(subjects.prefix(2)) { subject in
                            if let latestExam = getLatestExam(for: subject) {
                                let series: [SubjectScoreCard.Series] = [
                                    .init(name: subject.name, type: .myScore, dataPoints: subject.getScoreDataPoints())
                                ]
                                SubjectScoreCard(
                                    subjectName: subject.name,
                                    scoreText: String(Int(latestExam.score)),
                                    date: latestExam.date,
                                    iconSystemName: getSubjectIcon(for: subject),
                                    miniSeries: series
                                )
                            }
                        }
                        
                        // 如果没有数据，展示示例卡片
                        if subjects.isEmpty || subjects.allSatisfy({ getLatestExam(for: $0) == nil }) {
                            // 示例：数学卡片
                            let v1 = SubjectScoreCard(
                                subjectName: "数学",
                                scoreText: "125",
                                date: Date(),
                                iconSystemName: "function",
                                miniSeries: [
                                    .init(name: "我的分数", type: .myScore, dataPoints: [] )
                                ]
                            )
                            v1
                                .padding(.horizontal, 0)
                            
                            // 示例：班级排名卡片
                            Group {
                                Text("班级排名卡片 (28_2838)")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.top)
                            
                                // 构造一个简短的示例趋势序列（若真实数据源可用，请替换）
                                let rankSeries: [RankDataPoint] = [
                                    RankDataPoint(date: Date().addingTimeInterval(-86400*14), rank: 18, total: 50),
                                    RankDataPoint(date: Date().addingTimeInterval(-86400*7), rank: 12, total: 50),
                                    RankDataPoint(date: Date(), rank: 10, total: 50)
                                ]
                            
                                ClassRankingCard(rank: 10, total: 20, date: Date(), rankSeries: rankSeries)
                                    .padding(.horizontal)
                            
                                ClassRankingCard(rank: 3, total: 45, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
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
