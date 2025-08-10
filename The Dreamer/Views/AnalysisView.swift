//
//  AnalysisView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件定义了应用的数据分析视图界面。
// 它显示用户记录的所有考试和练习数据，并提供添加新数据和管理科目与模板的功能。

// 常用名词解释：
// - View: SwiftUI中的基本界面构建单元
// - struct: 一种数据结构，用于封装相关的属性和功能
// - body: View的必需属性，定义了界面的具体内容
// - State: 用于管理视图内部的状态变量
// - Environment: 用于访问应用程序级别的环境信息
// - Query: 用于从数据库查询数据
// - NavigationStack: 提供导航栏和层级导航的容器视图
// - List: 用于显示列表数据的视图
// - Sheet: 以弹窗形式显示的视图

// 导入构建用户界面所需的SwiftUI框架
import SwiftUI
// 导入用于数据存储和管理的SwiftData框架
import SwiftData
import Charts

// 定义可添加的数据类型枚举
enum AddableDataType: Identifiable {
    case exam
    case practice
    
    var id: String {
        switch self {
        case .exam:
            return "exam"
        case .practice:
            return "practice"
        }
    }
}

// 定义一个结构体，表示数据分析视图界面
struct AnalysisView: View {
    // 获取应用程序的数据存储上下文，用于数据操作
    @Environment(\.modelContext) private var modelContext
    
    // 查询所有科目，按orderIndex排序
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    // 查询所有可用的图表视图
    @Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]
    
    // 现有设置面板开关
    @State private var showingSettingsSheet = false
    
    // 新增：添加数据的状态（与 AllDataListView 保持一致）
    @State private var addableDataType: AddableDataType? = nil
    @State private var showingAddDataSheet = false
    
    // 获取可用的图表类型
    private var availableCharts: [(name: String, icon: String, destination: AnyView)] {
        // 准备折线图数据点（我的分数）
        let lineData: [ChartDataPoint] = exams.map { exam in
            ChartDataPoint(
                date: exam.date,
                score: exam.score,
                totalScore: exam.totalScore,
                examName: exam.name,
                subject: exam.subject?.name ?? "未知科目",
                type: .myScore
            )
        }
        let lineView = LineChartView(
            dataPoints: lineData,
            visibleLines: [.myScore],
            chartStyle: .smooth,
            showYAxisAsPercentage: false
        )

        // 柱状图：使用便利构造器（单科分布）
        let barView = BarChartView.singleSubjectDistribution(
            exams: exams,
            displayMode: .absoluteScore
        )

        // 散点图：使用便利构造器（按科目分类）
        let scatterView = ScatterChartView.examScatterChart(
            exams: exams,
            categoryType: .subject
        )

        // 饼图：使用便利构造器（科目分数占比，环形样式）
        let pieView = PieChartView.subjectRatioChart(
            exams: exams,
            chartType: .donut
        )

        return [
            ("折线图", "chart.line.uptrend.xyaxis", AnyView(lineView)),
            ("柱状图", "chart.bar", AnyView(barView)),
            ("散点图", "chart.dots.scatter", AnyView(scatterView)),
            ("饼图", "chart.pie", AnyView(pieView))
        ]
    }
    
    // 定义视图的主要内容
    var body: some View {
        // 创建一个导航视图，用于管理视图间的导航
        NavigationStack {
            List {
                // 科目分组
                Section("科目") {
                    if subjects.isEmpty {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                            Text("点击右上角 + 添加数据")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } else {
                        ForEach(subjects) { subject in
                            NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                HStack {
                                    Image(systemName: getSubjectIcon(for: subject))
                                        .foregroundColor(getSubjectColor(for: subject))
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(subject.name)
                                            .font(.headline)
                                        Text("满分 \(Int(subject.totalScore)) 分")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // 显示该科目的考试数量
                                    if !subject.exams.isEmpty {
                                        Text("\(subject.exams.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color(.systemGray5))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                // 图表分组
                Section("图表") {
                    // 数据列表入口
                    NavigationLink(destination: AllDataListView()) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("所有数据")
                                    .font(.headline)
                                Text("查看所有考试和练习记录")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if !exams.isEmpty {
                                Text("\(exams.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 各种图表
                    ForEach(availableCharts, id: \.name) { chart in
                        NavigationLink(destination: chart.destination) {
                            HStack {
                                Image(systemName: chart.icon)
                                    .foregroundColor(.orange)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(chart.name)
                                        .font(.headline)
                                    Text("查看\(chart.name)分析")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            // 导航栏标题设置
            .navigationTitle("数据库")
            // 添加工具栏按钮
            .toolbar {
                // 仅保留左上角设置按钮
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettingsSheet = true }) {
                        Image(systemName: "gear")
                    }
                }
                
                // 新增：右上角添加数据按钮（考试/练习）
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        Button {
                            addableDataType = .exam
                            DispatchQueue.main.async { showingAddDataSheet = true }
                        } label: {
                            Label("添加考试", systemImage: "doc.text.fill")
                        }
                        
                        Button {
                            addableDataType = .practice
                            DispatchQueue.main.async { showingAddDataSheet = true }
                        } label: {
                            Label("添加练习", systemImage: "pencil.and.ruler.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
                    .environment(\.modelContext, modelContext)
            }
            // 新增：展示添加数据视图
            .sheet(isPresented: $showingAddDataSheet) {
                AddDataView(dataType: $addableDataType, examToEdit: nil, preselectedSubject: nil)
                    .environment(\.modelContext, modelContext)
            }
        }
    }
    
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
    
    /// 获取指定科目的颜色
    private func getSubjectColor(for subject: Subject) -> Color {
        switch subject.name {
        case let name where name.contains("语文"):
            return .red
        case let name where name.contains("数学"):
            return .blue
        case let name where name.contains("英语"):
            return .green
        case let name where name.contains("物理"):
            return .purple
        case let name where name.contains("化学"):
            return .orange
        case let name where name.contains("生物"):
            return .mint
        case let name where name.contains("历史"):
            return .brown
        case let name where name.contains("地理"):
            return .cyan
        case let name where name.contains("政治"):
            return .indigo
        default:
            return .gray
        }
    }
}

// MARK: - 所有数据列表视图（保留原有功能）
struct AllDataListView: View {
    // 获取应用程序的数据存储上下文，用于数据操作
    @Environment(\.modelContext) private var modelContext
        
    // 使用@Query获取所有Exam记录，并按日期倒序排序
    @Query(filter: #Predicate<Exam> { _ in true }, sort: [SortDescriptor(\Exam.date, order: .reverse)]) private var exams: [Exam]
    
    // 获取所有考试组
    @Query(sort: \ExamGroup.createdDate, order: .reverse) private var examGroups: [ExamGroup]
    
    // 添加状态变量来控制是否按科目分组
    @SceneStorage("analysisView.groupBySubject") private var groupBySubject = false
    
    // 添加状态变量来存储要添加的数据类型
    @State private var addableDataType: AddableDataType? = nil
    
    // 定义一个状态变量，用于控制添加数据界面是否显示
    @State private var showingAddDataSheet = false
    
    // 添加状态变量来控制删除确认对话框
    @State private var showingDeleteAlert = false
    @State private var examToDelete: Exam? = nil
    @State private var deleteIndexSet: IndexSet? = nil
    @State private var deleteFromSubjectExams: [Exam]? = nil
    
    // MARK: - 撤销机制相关状态
    @StateObject private var undoManager = CustomUndoManager()
    @State private var showingUndoToast = false
    @State private var undoMessage = ""
    @State private var deletedExams: [Exam] = []
    
    // MARK: - 原生手势状态
    @State private var showingGestureHint = false
    @State private var multiSelectStarted = false
    
    /// 删除单个考试并显示撤销提示
    private func deleteSingleExam(_ exam: Exam) {
        // 保存删除的考试信息用于撤销
        deletedExams = [exam]
        
        // 从数据库中删除
        modelContext.delete(exam)
        
        // 显示撤销提示
        undoMessage = "已删除考试记录"
        showingUndoToast = true
        
        // 设置撤销操作
        undoManager.registerUndo(data: exam) {
            self.restoreDeletedExams()
        }
        
        print("[\(Date())] 删除考试: \(exam.name)，已设置撤销机制")
    }
    
    /// 恢复已删除的考试
    private func restoreDeletedExams() {
        for exam in deletedExams {
            modelContext.insert(exam)
        }
        
        do {
            try modelContext.save()
            print("[\(Date())] 成功恢复 \(deletedExams.count) 个考试记录")
        } catch {
            print("[\(Date())] 恢复考试记录时发生错误: \(error)")
        }
        
        deletedExams.removeAll()
        showingUndoToast = false
    }
    
    // 编辑模式相关状态变量
    @State private var isEditMode = false
    @State private var selectedExams: Set<Exam.ID> = []
    @State private var showingExamGroupSelection = false
    
    // 计算属性：按科目分组的考试
    private var sortedSubjects: [Subject] {
        Array(Set(exams.compactMap { $0.subject }))
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        // ZStack允许视图堆叠显示
        ZStack {
            // 如果数据为空，显示空状态
            if exams.isEmpty {
                // 显示空状态视图，提示用户添加数据
                EmptyStateView(
                    iconName: "tray.fill",
                    title: "暂无成绩记录",
                    message: "点击右上角的 \"添加数据\" 按钮，开始记录你的第一次成绩吧！"
                )
            } else {
                // 列表显示所有成绩
                List {
                    if groupBySubject {
                        // 按科目分组显示
                        ForEach(sortedSubjects) { subject in
                            Section(header: Text(subject.name)) {
                                // 获取该科目的所有考试
                                let subjectExams = exams.filter { $0.subject?.id == subject.id }
                                 
                                ForEach(subjectExams) { exam in
                                    if isEditMode {
                                        HStack {
                                            Button(action: {
                                                toggleExamSelection(exam)
                                            }) {
                                                Image(systemName: selectedExams.contains(exam.id) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(selectedExams.contains(exam.id) ? .blue : .gray)
                                            }
                                            ExamRowView(exam: exam)
                                            Spacer()
                                        }
                                    } else {
                                        NavigationLink(destination: ExamDetailView(exam: exam)) {
                                            // 显示考试记录的行视图
                                            ExamRowView(exam: exam)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                // 单个考试删除：直接删除并显示撤销提示
                                                deleteSingleExam(exam)
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                // 为列表项添加删除功能
                                .onDelete { indices in
                                    deleteIndexSet = indices
                                    deleteFromSubjectExams = subjectExams
                                    showingDeleteAlert = true
                                }
                            }
                        }
                    } else {
                        // 按时间排序显示（原有逻辑）
                        Section {
                            ForEach(exams) { exam in
                                if isEditMode {
                                    HStack {
                                        Button(action: {
                                            toggleExamSelection(exam)
                                        }) {
                                            Image(systemName: selectedExams.contains(exam.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedExams.contains(exam.id) ? .blue : .gray)
                                        }
                                        ExamRowView(exam: exam)
                                        Spacer()
                                    }
                                } else {
                                    NavigationLink(destination: ExamDetailView(exam: exam)) {
                                        ExamRowView(exam: exam)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            // 单个考试删除：直接删除并显示撤销提示
                                            deleteSingleExam(exam)
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .onDelete { indices in
                                deleteIndexSet = indices
                                deleteFromSubjectExams = nil
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
            }
        }
        // 导航栏标题设置
        .navigationTitle("所有数据")
        // 编辑模式下隐藏底部标签栏
        .toolbar(isEditMode ? .hidden : .visible, for: .tabBar)
        // 添加工具栏按钮
        .toolbar {
            // 顶部工具栏
            if isEditMode {
                // 左上角：全选按钮
                ToolbarItem(placement: .topBarLeading) {
                    Button("全选") {
                        if selectedExams.count == exams.count {
                            selectedExams.removeAll()
                        } else {
                            selectedExams = Set(exams.map { $0.id })
                        }
                    }
                }
                
                // 右上角：完成按钮
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .cancel) {
                        exitEditMode()
                    } label: {
                        Label("完成", systemImage: "checkmark")
                    }
                }
            } else {
                // 非编辑模式右侧：添加和更多按钮
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        Button {
                            addableDataType = .exam
                            DispatchQueue.main.async { showingAddDataSheet = true }
                        } label: {
                            Label("添加考试", systemImage: "doc.text.fill")
                        }
                        
                        Button {
                            addableDataType = .practice
                            DispatchQueue.main.async { showingAddDataSheet = true }
                        } label: {
                            Label("添加练习", systemImage: "pencil.and.ruler.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                    Menu {
                        Button {
                            enterEditMode()
                        } label: {
                            Label("选择", systemImage: "checkmark.circle")
                        }
                        .disabled(exams.isEmpty)

                        Divider()

                        Picker("排序方式", selection: $groupBySubject) {
                            Label("按科目分组", systemImage: "folder.fill").tag(true)
                            Label("按时间排序", systemImage: "clock.fill").tag(false)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            
            // 底部工具栏（编辑模式）
            if isEditMode {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        showingExamGroupSelection = true
                    } label: {
                        Label("添加到考试组", systemImage: "folder.badge.plus")
                    }
                    .disabled(selectedExams.isEmpty)

                    Button(role: .destructive) {
                        batchDeleteExams()
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                    .disabled(selectedExams.isEmpty)

                    Spacer()

                    Menu {
                        // 更多批量操作可以在这里添加
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddDataSheet) {
            AddDataView(dataType: $addableDataType, examToEdit: nil, preselectedSubject: nil)
                .environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showingExamGroupSelection) {
            ExamGroupSelectionView(
                selectedExamIds: selectedExams,
                onComplete: {
                    exitEditMode()
                }
            )
            .environment(\.modelContext, modelContext)
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if isEditMode {
                    // 批量删除
                    performBatchDelete()
                } else {
                    // 单个删除
                    performDelete()
                }
            }
        } message: {
            if isEditMode {
                let count = selectedExams.count
                if count > 1 {
                    Text("确定要删除这 \(count) 个考试记录吗？此操作无法撤销。")
                } else {
                    Text("确定要删除这个考试记录吗？此操作无法撤销。")
                }
            } else {
                if let indices = deleteIndexSet {
                    let count = indices.count
                    if count > 1 {
                        Text("确定要删除这 \(count) 个考试记录吗？此操作无法撤销。")
                    } else {
                        Text("确定要删除这个考试记录吗？此操作无法撤销。")
                    }
                } else {
                    Text("确定要删除这些考试记录吗？此操作无法撤销。")
                }
            }
        }
        .overlay(alignment: .bottom) {
            UndoToastView(
                message: undoMessage,
                onUndo: {
                    undoManager.performUndo()
                },
                isShowing: $showingUndoToast
            )
            .animation(.easeInOut(duration: 0.3), value: showingUndoToast)
        }
        .overlay(alignment: .top) {
            if showingGestureHint {
                GestureHintView()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showingGestureHint)
            }
        }
        .threeFingerTap {
            handleThreeFingerTap()
        }
        .twoFingerMultiSelect(
            onStart: {
                handleMultiSelectStart()
            },
            onMove: { location in
                handleMultiSelectMove(at: location)
            },
            onEnd: {
                handleMultiSelectEnd()
            }
        )
    }
    
    // MARK: - 私有方法
    private func performDelete() {
        if let indices = deleteIndexSet {
            if let subjectExams = deleteFromSubjectExams {
                for index in indices.sorted(by: >) {
                    modelContext.delete(subjectExams[index])
                }
            } else {
                for index in indices.sorted(by: >) {
                    modelContext.delete(exams[index])
                }
            }
        }
        
        deleteIndexSet = nil
        deleteFromSubjectExams = nil
    }
    
    // MARK: - 编辑模式相关方法
    
    private func enterEditMode() {
        isEditMode = true
        selectedExams.removeAll()
    }
    
    private func exitEditMode() {
        isEditMode = false
        selectedExams.removeAll()
    }
    
    private func toggleExamSelection(_ exam: Exam) {
        if selectedExams.contains(exam.id) {
            selectedExams.remove(exam.id)
        } else {
            selectedExams.insert(exam.id)
        }
    }
    
    private func batchDeleteExams() {
        // 批量删除前的确认
        if !selectedExams.isEmpty {
            // 找到所有要删除的考试
            let examIdsToDelete = Array(selectedExams)
            let examsToDelete = exams.filter { examIdsToDelete.contains($0.id) }
            
            if !examsToDelete.isEmpty {
                showingDeleteAlert = true
            }
        }
    }
    
    private func performBatchDelete() {
        let examIdsToDelete = Array(selectedExams)
        let examsToDelete = exams.filter { examIdsToDelete.contains($0.id) }
        
        for exam in examsToDelete {
            modelContext.delete(exam)
        }
    }
    
    // MARK: - 手势处理相关方法
    private func handleThreeFingerTap() {
        if !exams.isEmpty {
            showingGestureHint = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingGestureHint = false
            }
        }
    }
    
    private func handleMultiSelectStart() {
        if !multiSelectStarted && !exams.isEmpty {
            enterEditMode()
            multiSelectStarted = true
            
            // 显示手势提示
            showingGestureHint = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showingGestureHint = false
            }
        }
    }
    
    private func handleMultiSelectMove(at location: CGPoint) {
        // 可以在这里实现多选逻辑，比如根据手指位置选择列表项
        // 目前保持简单，不实现复杂的多选手势
    }
    
    private func handleMultiSelectEnd() {
        multiSelectStarted = false
    }
}

// 创建一个简单的行视图来显示成绩
struct ExamRowView: View {
    // 接收一个考试记录作为参数
    let exam: Exam
    
    // 定义视图的主要内容
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exam.name)
                    .font(.headline)
                Text(safeSubjectName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(exam.totalScore, specifier: "%.1f")")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(exam.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // 安全地获取考试的科目名称
    private var safeSubjectName: String {
        if let subject = exam.subject {
            return subject.name
        } else {
            return "未知科目"
        }
    }
}

// 预览代码，用于在设计时预览界面效果
#Preview {
    AnalysisView()
}
