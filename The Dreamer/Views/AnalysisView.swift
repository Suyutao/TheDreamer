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
    
    // 定义一个状态变量，用于控制设置界面是否显示
    @State private var showingSettingsSheet = false
    
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
    
    // 定义视图的主要内容
    var body: some View {
        // 创建一个导航视图，用于管理视图间的导航
        NavigationStack {
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
                        Button("完成", systemImage: "checkmark", role: .cancel) {
                            exitEditMode()
                        }
                    }
                } else {
                    // 非编辑模式左侧：设置按钮
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { showingSettingsSheet = true }) {
                            Image(systemName: "gear")
                        }
                    }
                    
                    // 非编辑模式右侧：添加和更多菜单
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
                
                // 底部工具栏（仅编辑模式）
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
                            // 未来扩展选项
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
            }
            // 添加数据界面的弹窗
            .sheet(isPresented: $showingAddDataSheet) {
                AddDataView(dataType: $addableDataType, examToEdit: nil)
                    .environment(\.modelContext, modelContext)
            }
            // 设置界面的弹窗
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
                    .environment(\.modelContext, modelContext)
            }
            // 批量操作弹窗
            // 考试组选择界面
            .sheet(isPresented: $showingExamGroupSelection) {
                ExamGroupSelectionView(
                    selectedExamIds: selectedExams,
                    onComplete: {
                        exitEditMode()
                    }
                )
                .environment(\.modelContext, modelContext)
            }
            // 删除确认对话框
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    if isEditMode {
                        // 批量删除模式
                        performBatchDelete()
                    } else {
                        // 单个删除模式（从列表删除）
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
            // 撤销提示条覆盖层
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
            // 手势提示覆盖层
            .overlay(alignment: .top) {
                if showingGestureHint {
                    GestureHintView()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showingGestureHint)
                }
            }
        }
        // 添加原生手势支持
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
    
    // 执行删除操作
    private func performDelete() {
        guard let indices = deleteIndexSet else { return }
        
        if let subjectExams = deleteFromSubjectExams {
            // 删除特定科目下的考试记录
            for index in indices {
                if let examIndex = exams.firstIndex(where: { $0.id == subjectExams[index].id }) {
                    modelContext.delete(exams[examIndex])
                }
            }
        } else {
            // 删除全局列表中的考试记录
            for index in indices {
                modelContext.delete(exams[index])
            }
        }
        
        // 清理状态变量
        deleteIndexSet = nil
        deleteFromSubjectExams = nil
    }
    
    // MARK: - 编辑模式相关方法
    
    /// 进入编辑模式
    private func enterEditMode() {
        isEditMode = true
        selectedExams.removeAll()
    }
    
    /// 退出编辑模式
    private func exitEditMode() {
        isEditMode = false
        selectedExams.removeAll()
    }
    
    /// 切换考试的选择状态
    private func toggleExamSelection(_ exam: Exam) {
        if selectedExams.contains(exam.id) {
            selectedExams.remove(exam.id)
        } else {
            selectedExams.insert(exam.id)
        }
    }
    
    /// 批量删除选中的考试
    private func batchDeleteExams() {
        let examsToDelete = exams.filter { selectedExams.contains($0.id) }
        let deleteCount = examsToDelete.count
        
        // 设置删除信息用于确认对话框
        deleteIndexSet = IndexSet(0..<deleteCount)
        deleteFromSubjectExams = nil
        
        // 显示确认对话框
        showingDeleteAlert = true
        
        print("[\(Date())] 准备批量删除 \(deleteCount) 个考试记录")
    }
    
    /// 执行批量删除操作（从确认对话框调用）
    private func performBatchDelete() {
        let examsToDelete = exams.filter { selectedExams.contains($0.id) }
        
        for exam in examsToDelete {
            modelContext.delete(exam)
        }
        
        do {
            try modelContext.save()
            print("[\(Date())] 批量删除 \(examsToDelete.count) 个考试记录成功")
        } catch {
            print("[\(Date())] 批量删除考试时发生错误: \(error)")
        }
        
        exitEditMode()
    }
    
    // MARK: - 原生手势处理方法
    
    /// 处理三指点击手势
    private func handleThreeFingerTap() {
        if !exams.isEmpty {
            enterEditMode()
            showingGestureHint = true
            
            // 3秒后自动隐藏提示
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingGestureHint = false
            }
        }
    }
    
    /// 处理多选手势开始
    private func handleMultiSelectStart() {
        if !isEditMode && !exams.isEmpty {
            enterEditMode()
            multiSelectStarted = true
        }
    }
    
    /// 处理多选手势移动
    private func handleMultiSelectMove(at location: CGPoint) {
        // 这里可以根据位置选择对应的考试项
        // 由于需要获取列表项的位置信息，这部分逻辑可能需要在具体的列表项中实现
    }
    
    /// 处理多选手势结束
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
