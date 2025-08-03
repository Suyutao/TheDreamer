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
    
    // 添加状态变量来控制是否按科目分组
    @SceneStorage("analysisView.groupBySubject") private var groupBySubject = false
    
    // 添加状态变量来存储要添加的数据类型
    @State private var addableDataType: AddableDataType? = nil
    
    // 定义一个状态变量，用于控制添加数据界面是否显示
    @State private var showingAddDataSheet = false
    
    // 定义一个状态变量，用于控制管理科目与模板界面是否显示
    @State private var showingManageSheet = false
    
    // 添加状态变量来控制删除确认对话框
    @State private var showingDeleteAlert = false
    @State private var examToDelete: Exam? = nil
    @State private var deleteIndexSet: IndexSet? = nil
    @State private var deleteFromSubjectExams: [Exam]? = nil
    
    
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
                            // 先获取所有有考试的科目，并安全地处理科目名称
                            let subjects = Array(Set(exams.compactMap { $0.subject }))
                                .sorted { subjectA, subjectB in
                                    // 安全地比较科目名称
                                    let nameA = subjectA.name
                                    let nameB = subjectB.name
                                    return nameA < nameB
                                }
                             
                            ForEach(subjects) { subject in
                                Section(header: Text(subject.name)) {
                                    // 获取该科目的所有考试
                                    let subjectExams = exams.filter { $0.subject?.id == subject.id }
                                     
                                    ForEach(subjectExams) { exam in
                                        NavigationLink(destination: ExamDetailView(exam: exam)) {
                                            // 显示考试记录的行视图
                                            ExamRowView(exam: exam)
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
                                    NavigationLink(destination: ExamDetailView(exam: exam)) {
                                        ExamRowView(exam: exam)
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
            // 添加工具栏按钮
            .toolbar {
                // 左上角的视图管理菜单
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("排序方式", selection: $groupBySubject) {
                            Label("按科目分组", systemImage: "folder.fill").tag(true)
                            Label("按时间排序", systemImage: "clock.fill").tag(false)
                        }
                        
                        Divider()
                        
                        Button(action: { showingManageSheet = true }) {
                            Label("管理科目与模板...", systemImage: "gearshape.fill")
                        }
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                
                // 右上角的添加数据菜单
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            addableDataType = .exam
                            DispatchQueue.main.async { showingAddDataSheet = true }
                        } label: {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("添加考试")
                            }
                        }
                        
                        Button {
                            addableDataType = .practice
                            DispatchQueue.main.async { showingAddDataSheet = true }
                        } label: {
                            HStack {
                                Image(systemName: "pencil.and.ruler.fill")
                                Text("添加练习")
                            }
                        }
                    } label: {
                        Text("添加数据")
                    }
                }
            }
            // 添加数据界面的弹窗
            .sheet(isPresented: $showingAddDataSheet) {
                AddDataView(dataType: $addableDataType)
                    .environment(\.modelContext, modelContext)
            }
            // 管理科目与模板界面的弹窗
            .sheet(isPresented: $showingManageSheet) {
                ManageSubjectsView()
                    .environment(\.modelContext, modelContext)
            }
            // 删除确认对话框
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    performDelete()
                }
            } message: {
                Text("确定要删除这些考试记录吗？此操作无法撤销。")
            }
        }
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
    
    // 安全地获取考试的科目名称
    private func safeSubjectName(for exam: Exam) -> String {
        if let subject = exam.subject {
            return subject.name
        } else {
            return "未知科目"
        }
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
