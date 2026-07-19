//
//  DashboardView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// Database 是应用的科目列表页，用于展示所有学习科目的概览信息。
// 根据Figma设计，显示科目卡片、科目描述和进度信息。

import SwiftUI
import SwiftData

/// Database 是应用的科目列表页，用于展示所有学习科目的概览信息。
struct Database: View {
    @Environment(\.modelContext) private var modelContext

    // 查询所有科目，按orderIndex排序
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    // 查询所有考试，按日期倒序
    @Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]

    @State private var showingSettingsSheet = false
    @State private var showingAddSubjectSheet = false

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

    /// 计算科目平均分
    private func getAverageScore(for subject: Subject) -> Double {
        guard !subject.exams.isEmpty else { return 0.0 }
        let totalScore = subject.exams.reduce(0) { $0 + $1.score }
        return totalScore / Double(subject.exams.count)
    }

    /// 计算科目最高分
    private func getHighestScore(for subject: Subject) -> Double {
        guard !subject.exams.isEmpty else { return 0.0 }
        return subject.exams.max { $0.score < $1.score }?.score ?? 0.0
    }

    var body: some View {
        NavigationStack {
            List {
                overviewStatsView
                pinnedSubjectsView
                allSubjectsView
            }
            .navigationTitle("科目概览")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: { showingSettingsSheet = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSubjectSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
                    .environment(\.modelContext, modelContext)
            }
            .sheet(isPresented: $showingAddSubjectSheet) {
                SubjectEditView(subject: nil, onSave: { name, score, subject in
                    let newSubject = Subject(name: name, totalScore: score, orderIndex: subjects.count)
                    modelContext.insert(newSubject)
                    try? modelContext.save()
                })
            }
        }
    }

    // MARK: - 子视图组件

    /// 顶部统计概览视图
    private var overviewStatsView: some View {
        Section {
            LabeledContent("科目", value: "\(subjects.count)")
            LabeledContent("考试", value: "\(exams.count)")
            LabeledContent("当前周", value: "\(currentWeek)")
        } header: {
            Text("总览")
        }
    }

    /// 置顶科目视图
    private var pinnedSubjectsView: some View {
        let pinnedSubjects = subjects.filter { $0.pinned }.sorted { $0.orderIndex < $1.orderIndex }

        return Section("置顶") {
            if pinnedSubjects.isEmpty {
                Text("暂无置顶科目")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(pinnedSubjects) { subject in
                    subjectRow(for: subject)
                }
            }
        }
    }

    /// 所有科目视图
    private var allSubjectsView: some View {
        Section("全部科目") {
            if subjects.isEmpty {
                EmptyStateView(
                    iconName: "books.vertical.fill",
                    title: "尚无科目",
                    message: "点击右上角的 '+' 按钮来创建你的第一个学习科目"
                )
            } else {
                let unpinnedSubjects = subjects.filter { !$0.pinned }.sorted { $0.orderIndex < $1.orderIndex }

                ForEach(unpinnedSubjects) { subject in
                    subjectRow(for: subject)
                }
            }
        }
    }

    private func subjectRow(for subject: Subject) -> some View {
        SubjectOverviewCard(
            subject: subject,
            latestExam: getLatestExam(for: subject),
            averageScore: getAverageScore(for: subject),
            highestScore: getHighestScore(for: subject),
            iconSystemName: getSubjectIcon(for: subject)
        )
    }
}

/// 科目概览卡片组件
struct SubjectOverviewCard: View {
    let subject: Subject
    let latestExam: Exam?
    let averageScore: Double
    let highestScore: Double
    let iconSystemName: String

    var body: some View {
        NavigationLink(destination: SubjectDetailView(subject: subject)) {
            VStack(alignment: .leading, spacing: 10) {
                // 顶部信息行
                HStack {
                    // 图标和科目名称
                    HStack(spacing: 12) {
                        Image(systemName: iconSystemName)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(subject.name)
                                .font(.headline)
                                .fontWeight(.semibold)

                            if !subject.subjectDescription.isEmpty {
                                Text(subject.subjectDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }

                    Spacer()

                    // 置顶标记
                    if subject.pinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // 分数信息行
                HStack {
                    // 最新分数
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最新")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let exam = latestExam {
                            Text("\(Int(exam.score))/\(Int(exam.totalScore))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        } else {
                            Text("暂无数据")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // 平均分
                    VStack(alignment: .center, spacing: 2) {
                        Text("平均")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if subject.exams.isEmpty {
                            Text("--")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text(String(format: "%.1f", averageScore))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }

                    Spacer()

                    // 最高分
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("最高")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if subject.exams.isEmpty {
                            Text("--")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(Int(highestScore))/\(Int(subject.totalScore))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }

                // 进度条
                if !subject.exams.isEmpty {
                    HStack {
                        Text("考试次数")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(subject.exams.count) 次")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: Double(subject.exams.count), total: 10.0)
                        .tint(.accentColor)
                }
            }
        }
    }
}

#Preview {
    Database()
}
