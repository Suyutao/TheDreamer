//
//  DashboardAnalysisView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// DashboardAnalysisView 是应用的数据分析页面，用于展示详细的学习数据分析图表。
// 根据Figma设计，包含时间选择器、统计卡片和多种数据可视化图表。

import SwiftUI
import SwiftData
import Charts

/// DashboardAnalysisView 是应用的数据分析页面，用于展示详细的学习数据分析图表。
struct DashboardAnalysisView: View {
    @Environment(\.modelContext) private var modelContext

    // 查询所有科目，按orderIndex排序
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    // 查询所有考试，按日期正序（用于图表）
    @Query(sort: \Exam.date) private var exams: [Exam]

    @State private var selectedTimeRange: TimeRange = .lastMonth
    @State private var selectedSubject: Subject?

    enum TimeRange: String, CaseIterable {
        case lastWeek = "最近一周"
        case lastMonth = "最近一月"
        case lastThreeMonths = "最近三月"
        case allTime = "全部时间"

        var dateRange: ClosedRange<Date>? {
            let now = Date()
            let calendar = Calendar.current

            switch self {
            case .lastWeek:
                let startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
                return startDate...now
            case .lastMonth:
                let startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return startDate...now
            case .lastThreeMonths:
                let startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
                return startDate...now
            case .allTime:
                return nil
            }
        }
    }

    /// 获取指定时间范围内的考试数据
    private func getFilteredExams() -> [Exam] {
        guard let dateRange = selectedTimeRange.dateRange else {
            return exams
        }
        return exams.filter { dateRange.contains($0.date) }
    }

    /// 计算总体统计数据
    private func calculateOverallStats() -> (totalExams: Int, averageScore: Double, improvementRate: Double) {
        let filteredExams = getFilteredExams()

        guard !filteredExams.isEmpty else {
            return (0, 0.0, 0.0)
        }

        let totalExams = filteredExams.count
        let totalScore = filteredExams.reduce(0) { $0 + $1.score }
        let averageScore = totalScore / Double(totalExams)

        // 计算提升率（最近3次考试与最早3次考试的对比）
        let sortedExams = filteredExams.sorted { $0.date < $1.date }
        var improvementRate: Double = 0.0

        if sortedExams.count >= 6 {
            let recentScores = sortedExams.suffix(3).map { $0.score / $0.totalScore }
            let earlyScores = sortedExams.prefix(3).map { $0.score / $0.totalScore }

            let recentAvg = recentScores.reduce(0, +) / 3.0
            let earlyAvg = earlyScores.reduce(0, +) / 3.0

            improvementRate = earlyAvg > 0 ? ((recentAvg - earlyAvg) / earlyAvg) * 100 : 0.0
        }

        return (totalExams, averageScore, improvementRate)
    }

    /// 按科目分组获取考试数据
    private func getExamsBySubject() -> [(subject: Subject, exams: [Exam])] {
        let filteredExams = getFilteredExams()
        let groupedExams = Dictionary(grouping: filteredExams, by: { $0.subject })

        return subjects.compactMap { subject in
            let subjectExams = groupedExams[subject] ?? []
            return !subjectExams.isEmpty ? (subject, subjectExams) : nil
        }
    }

    var body: some View {
        NavigationStack {
            List {
                timeRangeSelectorView
                overallStatsView
                subjectComparisonView
                trendChartView
                detailTableView
            }
            .navigationTitle("数据分析")
        }
    }

    // MARK: - 子视图组件

    /// 时间范围选择器视图
    private var timeRangeSelectorView: some View {
        Section("时间范围") {
            Picker("时间范围", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    /// 总体统计卡片视图
    private var overallStatsView: some View {
        let stats = calculateOverallStats()

        return Section("总体概览") {
            LabeledContent("考试次数", value: "\(stats.totalExams)")
            LabeledContent("平均分", value: String(format: "%.1f", stats.averageScore))
            LabeledContent("提升率", value: String(format: "%.1f%%", stats.improvementRate))
        }
    }

    /// 科目表现对比视图
    private var subjectComparisonView: some View {
        let subjectData = getExamsBySubject()

        return Section {
            HStack {
                if !subjects.isEmpty {
                    Picker("科目", selection: $selectedSubject) {
                        Text("全部").tag(nil as Subject?)
                        ForEach(subjects) { subject in
                            Text(subject.name).tag(subject as Subject?)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            if subjectData.isEmpty {
                EmptyStateView(
                    iconName: "chart.bar.doc.horizontal",
                    title: "暂无数据",
                    message: "当前时间范围内没有考试数据"
                )
            } else {
                // 科目对比图表
                SubjectComparisonChart(
                    subjectData: selectedSubject != nil ?
                        subjectData.filter { $0.subject == selectedSubject } :
                        subjectData
                )

                // 科目平均分排名
                SubjectRankingView(subjectData: subjectData)
            }
        } header: {
            Text("科目表现")
        }
    }

    /// 趋势图表视图
    private var trendChartView: some View {
        let filteredExams = getFilteredExams()

        return Section("成绩趋势") {
            if filteredExams.isEmpty {
                EmptyStateView(
                    iconName: "line.chart.ascending",
                    title: "暂无趋势数据",
                    message: "需要至少2次考试记录才能显示趋势"
                )
            } else {
                ScoreTrendChart(exams: filteredExams)
            }
        }
    }

    /// 详细数据表格视图
    private var detailTableView: some View {
        let filteredExams = getFilteredExams().sorted { $0.date > $1.date }

        return Section {
            if filteredExams.isEmpty {
                Text("暂无考试记录")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(filteredExams.prefix(10)) { exam in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exam.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)

                                Text(exam.subject?.name ?? "未知科目")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(Int(exam.score))/\(Int(exam.totalScore))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                let percentage = (exam.score / exam.totalScore) * 100
                                Text(String(format: "%.1f%%", percentage))
                                    .font(.caption)
                                    .foregroundColor(percentage >= 80 ? .green : percentage >= 60 ? .orange : .red)
                            }

                            VStack(alignment: .trailing, spacing: 4) {
                                Text(exam.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6).opacity(0.3))
                        )
                    }

                    if filteredExams.count > 10 {
                        Text("还有 \(filteredExams.count - 10) 条记录...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
        } header: {
            Text("详细记录")
        } footer: {
            Text("\(filteredExams.count) 条记录")
        }
    }
}

/// 科目对比图表组件
struct SubjectComparisonChart: View {
    let subjectData: [(subject: Subject, exams: [Exam])]

    var body: some View {
        VStack(spacing: 8) {
            Chart {
                ForEach(subjectData, id: \.subject.id) { data in
                    SubjectComparisonBar(data: data)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
    }
}

/// 科目排名视图组件
struct SubjectRankingView: View {
    let subjectData: [(subject: Subject, exams: [Exam])]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(subjectData.enumerated().sorted { $0.element.exams.averageScore > $1.element.exams.averageScore }), id: \.element.subject.id) { index, data in
                let avgScore = data.exams.reduce(0) { $0 + $1.score } / Double(data.exams.count)
                let percentage = (avgScore / data.subject.totalScore) * 100

                HStack {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    Text(data.subject.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.1f", avgScore))
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(String(format: "%.1f%%", percentage))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6).opacity(0.5))
                )
            }
        }
    }
}

/// 成绩趋势图表组件
struct ScoreTrendChart: View {
    let exams: [Exam]

    var body: some View {
        VStack(spacing: 8) {
            Chart {
                ForEach(exams, id: \.id) { exam in
                    LineMark(
                        x: .value("日期", exam.date),
                        y: .value("分数", exam.score)
                    )
                    .foregroundStyle(Color.blue)
                    .symbol(.circle)

                    // 添加平均分参考线
                    if exam == exams.first {
                        RuleMark(
                            y: .value("平均分", exams.reduce(0) { $0 + $1.score } / Double(exams.count))
                        )
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .top) {
                            Text("平均分")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
    }
}

/// 科目对比柱状图组件
struct SubjectComparisonBar: ChartContent {
    let data: (subject: Subject, exams: [Exam])

    var body: some ChartContent {
        let avgScore = data.exams.reduce(0.0) { $0 + $1.score } / Double(data.exams.count)

        BarMark(
            x: .value("科目", data.subject.name),
            y: .value("平均分", avgScore)
        )
        .foregroundStyle(by: .value("科目", data.subject.name))
        .opacity(0.8)
    }
}

// MARK: - Array Extension
extension Array where Element == Exam {
    var averageScore: Double {
        guard !isEmpty else { return 0.0 }
        return reduce(0) { $0 + $1.score } / Double(count)
    }
}

#Preview {
    DashboardAnalysisView()
}
