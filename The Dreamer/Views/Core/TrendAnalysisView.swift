import SwiftUI
import SwiftData

/// 趋势分析视图 - M1 里程碑的核心视图
struct TrendAnalysisView: View {
    // MARK: - 环境
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - 查询数据
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    @Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]
    
    // MARK: - 输入参数（从 AnalysisView 传入）
    let selectedSubjects: Set<Subject.ID>
    let dateRange: AnalysisView.TrendDateRange
    
    // MARK: - 本地状态
    @State private var localSelectedSubjects: Set<Subject.ID>
    @State private var localDateRange: AnalysisView.TrendDateRange
    @State private var showYAxisAsPercentage = false
    @State private var customStartDate = Date().addingTimeInterval(-86400 * 30)
    @State private var customEndDate = Date()
    
    // MARK: - 初始化
    init(selectedSubjects: Set<Subject.ID> = [], dateRange: AnalysisView.TrendDateRange = .recent30Days) {
        self.selectedSubjects = selectedSubjects
        self.dateRange = dateRange
        // 如果传入的选择集合为空，默认选择前3个科目
        if selectedSubjects.isEmpty {
            self._localSelectedSubjects = State(initialValue: Set())
        } else {
            self._localSelectedSubjects = State(initialValue: selectedSubjects)
        }
        self._localDateRange = State(initialValue: dateRange)
    }
    
    // MARK: - 计算属性
    
    /// 有效的日期范围
    private var effectiveDateRange: ClosedRange<Date>? {
        switch localDateRange {
        case .all:
            return nil
        case .recent30Days, .recent90Days:
            guard let startDate = localDateRange.dateFilter else { return nil }
            return startDate...Date()
        case .custom:
            return customStartDate...customEndDate
        }
    }
    
    /// 选中的科目对象列表
    private var selectedSubjectObjects: [Subject] {
        subjects.filter { localSelectedSubjects.contains($0.id) }
    }
    
    /// 为每个选中科目生成序列数据
    private func getSeriesForSubject(_ subject: Subject) -> [SubjectScoreCard.Series] {
        let dataPoints = subject.getScoreDataPoints(in: effectiveDateRange)
        if dataPoints.isEmpty {
            return []
        }
        return [
            SubjectScoreCard.Series(
                name: subject.name,
                type: .myScore,
                dataPoints: dataPoints
            )
        ]
    }
    
    // MARK: - 视图主体
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 筛选控件
                    filterControls
                    
                    // 科目趋势图列表
                    if selectedSubjectObjects.isEmpty {
                        emptySubjectState
                    } else {
                        ForEach(selectedSubjectObjects) { subject in
                            subjectTrendChart(for: subject)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("分数趋势")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // 如果没有选择科目且有可用科目，默认选择前3个
                if localSelectedSubjects.isEmpty && !subjects.isEmpty {
                    localSelectedSubjects = Set(subjects.prefix(3).map { $0.id })
                }
            }
        }
    }
    
    // MARK: - 子视图组件
    
    /// 筛选控件区域
    private var filterControls: some View {
        VStack(spacing: 12) {
            // 科目选择
            subjectSelectionSection
            
            // 日期范围选择
            dateRangeSection
            
            // 显示选项
            displayOptionsSection
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    /// 科目选择区域
    private var subjectSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择科目")
                .font(.headline)
                .foregroundColor(.primary)
            
            if subjects.isEmpty {
                Text("暂无科目，请先添加科目")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(subjects) { subject in
                        Button(action: {
                            toggleSubjectSelection(subject)
                        }) {
                            HStack {
                                Image(systemName: localSelectedSubjects.contains(subject.id) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(localSelectedSubjects.contains(subject.id) ? .blue : .secondary)
                                Text(subject.name)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                localSelectedSubjects.contains(subject.id) 
                                ? Color.blue.opacity(0.1) 
                                : Color(.tertiarySystemGroupedBackground)
                            )
                            .cornerRadius(6)
                        }
                    }
                }
            }
        }
    }
    
    /// 日期范围选择区域
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("时间范围")
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker("时间范围", selection: $localDateRange) {
                ForEach(AnalysisView.TrendDateRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // 自定义日期选择器
            if localDateRange == .custom {
                VStack(spacing: 8) {
                    DatePicker("开始日期", selection: $customStartDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    DatePicker("结束日期", selection: $customEndDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                .padding(.top, 8)
            }
        }
    }
    
    /// 显示选项区域
    private var displayOptionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("显示选项")
                .font(.headline)
                .foregroundColor(.primary)
            
            Toggle("Y轴显示为百分比", isOn: $showYAxisAsPercentage)
                .font(.caption)
        }
    }
    
    /// 空科目状态
    private var emptySubjectState: some View {
        EmptyStateView(
            iconName: "chart.line.uptrend.xyaxis",
            title: "未选择科目",
            message: "请至少选择一个科目查看趋势分析"
        )
        .padding(.top, 40)
    }
    
    /// 单个科目的趋势图
    private func subjectTrendChart(for subject: Subject) -> some View {
        let series = getSeriesForSubject(subject)
        let latestExam = subject.exams.sorted { $0.date > $1.date }.first
        
        return SubjectScoreCard(
            subjectName: subject.name,
            scoreText: String(Int(latestExam?.score ?? 0)),
            date: latestExam?.date ?? Date(),
            iconSystemName: getSubjectIcon(for: subject),
            miniSeries: series,
            showYAxisAsPercentage: showYAxisAsPercentage
        )
    }
    
    // MARK: - 辅助方法
    
    /// 切换科目选择状态
    private func toggleSubjectSelection(_ subject: Subject) {
        if localSelectedSubjects.contains(subject.id) {
            localSelectedSubjects.remove(subject.id)
        } else {
            localSelectedSubjects.insert(subject.id)
        }
    }
    
    /// 获取科目图标
    private func getSubjectIcon(for subject: Subject) -> String {
        switch subject.name {
        case "数学":
            return "function"
        case "语文":
            return "textformat"
        case "英语":
            return "textformat.abc"
        case "物理":
            return "atom"
        case "化学":
            return "flask"
        case "生物":
            return "leaf"
        case "政治":
            return "flag"
        case "历史":
            return "book.closed"
        case "地理":
            return "globe.asia.australia"
        default:
            return "book"
        }
    }
}

#Preview {
    TrendAnalysisView(
        selectedSubjects: [],
        dateRange: .recent30Days
    )
}