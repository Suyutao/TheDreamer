//
//  SubjectDetailView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

/// [V22] 科目详情视图。显示科目的基本信息和操作选项。
struct SubjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let subjectID: PersistentIdentifier
    
    // 状态变量控制sheet的显示
    @State private var showingEditSheet = false
    @State private var showingAddDataSheet = false
    @State private var addableDataType: AddableDataType? = nil
    
    // 新增：本地状态 - 时间范围分段
    @State private var selectedRange: TimeRangeSelector.TimeRange = .month
    
    init(subject: Subject) {
        self.subjectID = subject.persistentModelID
    }
    
    // MARK: - Helper
    /// 获取指定科目的SF Symbol图标
    private func getSubjectIcon(for subject: Subject) -> String {
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
    
    /// 获取指定科目的最新考试记录
    private func getLatestExam(for subject: Subject) -> Exam? {
        subject.exams.sorted { $0.date > $1.date }.first
    }
    
    // 根据分段选择计算图表的数据点
    private func chartDataPoints(for subject: Subject) -> [ChartDataPoint] {
        let range = selectedRange.dateRange
        return subject.getScoreDataPoints(in: range)
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if let subject = modelContext.model(for: subjectID) as? Subject {
                List {
                    headerSection(subject: subject)
                    statisticsSection(subject: subject)
                    chartSection(subject: subject)
                    descriptionSection(subject: subject)
                    optionsSection(subject: subject)
                    actionButtonsSection(subject: subject)
                }
                .navigationTitle(subject.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            addableDataType = .exam
                            showingAddDataSheet = true
                        }) {
                            Label("添加考试记录", systemImage: "plus")
                        }
                    }
                }
                // 编辑科目的sheet
                .sheet(isPresented: $showingEditSheet) {
                    SubjectEditView(subject: subject) { name, totalScore, editedSubject in
                        if let editedSubject = editedSubject {
                            editedSubject.name = name
                            editedSubject.totalScore = totalScore
                            editedSubject.markAsUpdated()
                            try? modelContext.save()
                        }
                    }
                }
                // 添加数据的sheet
                .sheet(isPresented: $showingAddDataSheet) {
                    AddDataView(
                        dataType: $addableDataType,
                        examToEdit: nil,
                        preselectedSubject: subject
                    )
                }
            } else {
                EmptyStateView(
                    iconName: "exclamationmark.triangle.fill",
                    title: "科目不存在",
                    message: "该科目已被删除或不存在。"
                )
                .navigationTitle("科目详情")
                .onAppear { dismiss() }
            }
        }
    }

    // MARK: - 子视图组件

    /// 顶部标题和操作栏
    private func headerSection(subject: Subject) -> some View {
        Section {
            // 科目图标和基本信息
            HStack(spacing: 16) {
                Image(systemName: getSubjectIcon(for: subject))
                    .font(.title)
                    .foregroundStyle(.tint)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 8) {
                    Text(subject.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("满分: \(Int(subject.totalScore))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        Label("\(subject.exams.count)", systemImage: "doc.text")
                        Label("\(subject.practiceCollections.count)", systemImage: "pencil.and.ruler")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    /// 统计卡片区域
    private func statisticsSection(subject: Subject) -> some View {
        let latestExam = getLatestExam(for: subject)
        let avgScore = subject.exams.isEmpty ? 0.0 :
            subject.exams.reduce(0) { $0 + $1.score } / Double(subject.exams.count)
        let highestScore = subject.exams.isEmpty ? 0.0 :
            subject.exams.max { $0.score < $1.score }?.score ?? 0.0

        return Section("数据统计") {
            TimeRangeSelector(selectedRange: $selectedRange)
            LabeledContent("最新成绩", value: latestExam.map { "\(Int($0.score))/\(Int($0.totalScore))" } ?? "--")
            LabeledContent("平均分", value: String(format: "%.1f/%d", avgScore, Int(subject.totalScore)))
            LabeledContent("最高分", value: "\(Int(highestScore))/\(Int(subject.totalScore))")
        }
    }

    /// 图表区域
    private func chartSection(subject: Subject) -> some View {
        Section {
            let points = chartDataPoints(for: subject)
            VStack(spacing: 12) {
                if points.isEmpty {
                    ContentUnavailableView(
                        "暂无数据",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("添加考试记录后查看成绩趋势")
                    )
                    .frame(height: 200)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("最近成绩变化")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LineChartView(
                            dataPoints: points,
                            selectedSubject: subject.name,
                            dateRange: selectedRange.dateRange,
                            visibleLines: [.myScore],
                            chartStyle: .smooth,
                            showYAxisAsPercentage: false
                        )
                        .frame(height: 200)
                    }
                }
            }
        } header: {
            Text("成绩趋势")
        } footer: {
            Text(selectedRange.rawValue)
        }
    }

    /// 科目描述区域
    private func descriptionSection(subject: Subject) -> some View {
        Section {
            if subject.subjectDescription.isEmpty {
                Button("添加描述") {
                    showingEditSheet = true
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(subject.subjectDescription)
                        .font(.subheadline)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } header: {
            Text("科目描述")
        } footer: {
            Button("编辑科目描述") {
                showingEditSheet = true
            }
        }
    }

    /// 选项和操作区域
    private func optionsSection(subject: Subject) -> some View {
        Section("设置选项") {
            Toggle("在概览中置顶", isOn: Binding(
                get: { subject.pinned },
                set: { newValue in
                    subject.pinned = newValue
                    subject.markAsUpdated()
                    try? modelContext.save()
                }
            ))

            NavigationLink(destination: SubjectDataView(subject: subject)) {
                Label("查看所有数据", systemImage: "list.bullet")
            }
        }
    }

    /// 底部操作按钮
    private func actionButtonsSection(subject: Subject) -> some View {
        Section {
            // 添加数据按钮
            Button(action: {
                addableDataType = .exam
                showingAddDataSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("添加考试记录")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            // 添加练习按钮
            Button(action: {
                addableDataType = .practice
                showingAddDataSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("添加练习记录")
                }
                .frame(maxWidth: .infinity)
            }

            // 编辑科目按钮
            Button(action: { showingEditSheet = true }) {
                Text("编辑科目信息")
            }
        }
    }

}

#Preview {
    // 创建内存中的模型容器用于预览
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subject.self, configurations: config)
    let context = container.mainContext

    // 创建示例科目
    let subject = Subject(name: "数学", totalScore: 150, orderIndex: 0)
    context.insert(subject)
    try? context.save()

    return SubjectDetailView(subject: subject)
        .modelContainer(container)
}
