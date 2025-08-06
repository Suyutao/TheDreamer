//
//  ManageSubjectsView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// ManageSubjectsView 是一个用于管理学习科目的视图。
// 它允许用户查看、添加、编辑和删除科目，并可以调整科目的显示顺序。
// 该视图使用SwiftData进行数据持久化，并使用OSLog进行日志记录。

// 常用名词说明：
// View: SwiftUI 中的视图协议，用于定义用户界面。
// struct: Swift 中的结构体，用于定义自定义数据类型。
// body: View 协议中的计算属性，用于定义视图的层次结构。
// State: SwiftUI 中的属性包装器，用于管理视图的内部状态。
// Environment: SwiftUI 中的属性包装器，用于访问环境中的值。
// Query: SwiftData 中的属性包装器，用于查询数据。
// Logger: OSLog 框架中的类，用于记录日志信息。
// NavigationView: SwiftUI 中的视图容器，用于管理导航层次结构。
// List: SwiftUI 中的视图，用于显示列表数据。
// ForEach: SwiftUI 中的视图，用于遍历数据并生成视图。
// Button: SwiftUI 中的视图，用于响应用户点击事件。
// Sheet: SwiftUI 中的视图，用于以模态方式显示其他视图。
// Alert: SwiftUI 中的视图，用于显示警告信息。

// 导入SwiftUI框架用于构建用户界面
// 导入SwiftData框架用于数据持久化
// 导入OSLog框架用于日志记录
import SwiftUI
import SwiftData
import OSLog

/// ManageSubjectsView 是一个用于管理学习科目的视图。
/// 它允许用户查看、添加、编辑和删除科目，并可以调整科目的显示顺序。
struct ManageSubjectsView: View {
    // MARK: - Properties & State
    
    /// 创建日志对象，用于记录日志信息。
    private let logger = Logger(subsystem: "com.suyutao.The-Dreamer", category: "ManageSubjectsView")
    
    /// 获取当前的模型上下文，用于数据操作。
    @Environment(\.modelContext) private var modelContext
    
    /// 获取dismiss环境值，用于关闭当前视图。
    @Environment(\.dismiss) private var dismiss
    // 查询Subject对象，按orderIndex排序
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    
    /// 状态变量，控制编辑科目表单是否显示。
    @State private var isShowingSheet = false
    
    /// 状态变量，保存正在编辑的科目对象。
    @State private var subjectToEdit: Subject?
    
    /// 状态变量，控制列表的编辑模式。
    #if os(iOS)
    @State private var editMode: EditMode = .inactive
    #endif
    
    /// 状态变量，控制警告弹窗是否显示。
    @State private var showingAlert = false
    
    /// 状态变量，保存警告弹窗的消息内容。
    @State private var alertMessage = ""
    
    // MARK: - Computed Properties
    
    /// 视图的主体部分。
    var body: some View {
        // 使用NavigationView包装内容
        NavigationView {
            // 使用ZStack实现层叠布局
            ZStack {
                // 当科目列表为空时显示空状态视图
                if subjects.isEmpty {
                    EmptyStateView(
                        iconName: "books.vertical.fill",
                        title: "尚无科目",
                        message: "点击右上角的 '+' 按钮来创建你的第一个学习科目")
                } else {
                    // 当科目列表不为空时显示列表
                    List {
                        // 遍历所有科目
                        ForEach(subjects) { subject in
                            ZStack {
                                NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                SubjectRow(subject: subject)
                                    .contentShape(Rectangle())
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = subjects.firstIndex(where: { $0.id == subject.id }) {
                                        deleteSubject(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                        // 为列表添加删除功能
                        .onDelete(perform: deleteSubject)
                        // 为列表添加拖动排序功能
                        .onMove(perform: moveSubject)
                    }
                }
            }
            // 设置工具栏内容
            .toolbar {
                // 取消按钮，用于关闭当前视图
                ToolbarItem(placement: .cancellationAction) { Button("完成") { dismiss() } }
                // 数据清理按钮（仅在非编辑模式下显示）
                ToolbarItem(placement: .secondaryAction) {
                    Button(action: triggerDataIntegrityCheck) {
                        Image(systemName: "trash.circle")
                    }
                    #if os(iOS)
                    .opacity(editMode.isEditing ? 0 : 1)
                    #endif
                }
                // 编辑按钮，用于切换编辑模式
                #if os(iOS)
                ToolbarItem(placement: .primaryAction) { EditButton() }
                #endif
                // 添加按钮，用于添加新科目
                ToolbarItem(placement: .primaryAction) {
                    Button(action: showAddSheet) { Image(systemName: "plus") }
                        // 在编辑模式下隐藏添加按钮
                        #if os(iOS)
                        .opacity(editMode.isEditing ? 0 : 1)
                        #endif
                }
            }
            // 设置表单页面
            .sheet(isPresented: $isShowingSheet) {
                SubjectEditView(subject: subjectToEdit, onSave: save)
            }
            // 设置警告弹窗
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("提醒"), message: Text(alertMessage), dismissButton: .default(Text("好")))
            }
            // 设置编辑模式环境值
            #if os(iOS)
            .environment(\.editMode, $editMode)
            #endif
        }
    }

    // MARK: - Functions
    
    /// 拖动排序函数，处理科目在列表中的拖动排序。
    /// - Parameters:
    ///   - source: 源索引集合
    ///   - destination: 目标索引
    private func moveSubject(from source: IndexSet, to destination: Int) {
        logger.info("拖动排序科目，源索引: \(source), 目标索引: \(destination)")
        
        // 创建一个可变的科目数组副本
        var reorderedSubjects = subjects
        
        // 执行移动操作
        reorderedSubjects.move(fromOffsets: source, toOffset: destination)
        
        // 更新所有科目的orderIndex以反映新的顺序
        for (index, subject) in reorderedSubjects.enumerated() {
            subject.orderIndex = index
            logger.info("更新科目 \(subject.name) 的orderIndex为: \(index)")
        }
        
        logger.info("完成拖动排序")
    }

    /// 删除科目函数，从列表中删除指定索引的科目。
    /// - Parameter offsets: 要删除的科目索引集合。
    private func deleteSubject(at offsets: IndexSet) {
        logger.info("尝试删除科目，删除索引: \(offsets)")
        
        // 收集要删除的科目信息用于确认对话框
        var subjectsToDelete: [(subject: Subject, examCount: Int, practiceCount: Int, templateCount: Int)] = []
        
        offsets.forEach { index in
            let subject = subjects[index]
            let examCount = subject.exams.count
            let practiceCount = subject.practiceCollections.count
            let templateCount = subject.paperTemplates.count
            
            subjectsToDelete.append((subject, examCount, practiceCount, templateCount))
        }
        
        // 如果有关联数据，显示详细的删除确认对话框
        let hasRelatedData = subjectsToDelete.contains { $0.examCount > 0 || $0.practiceCount > 0 || $0.templateCount > 0 }
        
        if hasRelatedData {
            // 构建详细的警告消息
            var warningMessage = "删除科目将同时删除以下数据：\n\n"
            
            for item in subjectsToDelete {
                warningMessage += "• \(item.subject.name)\n"
                if item.examCount > 0 {
                    warningMessage += "  - \(item.examCount) 场考试\n"
                }
                if item.practiceCount > 0 {
                    warningMessage += "  - \(item.practiceCount) 个练习组\n"
                }
                if item.templateCount > 0 {
                    warningMessage += "  - \(item.templateCount) 个模板\n"
                }
                warningMessage += "\n"
            }
            
            warningMessage += "此操作无法撤销，请确认是否继续？"
            
            // 显示确认对话框
            let alert = UIAlertController(
                title: "确认删除科目",
                message: warningMessage,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "了解后果，确认删除", style: .destructive) { _ in
                self.performSubjectDeletion(subjectsToDelete.map { $0.subject })
            })
            
            // 获取当前的UIViewController来显示alert
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        } else {
            // 没有关联数据，直接删除
            performSubjectDeletion(subjectsToDelete.map { $0.subject })
        }
    }
    
    /// 执行科目删除操作
    /// - Parameter subjects: 要删除的科目列表
    private func performSubjectDeletion(_ subjects: [Subject]) {
        subjects.forEach { subject in
            logger.info("删除科目: \(subject.name)")
            modelContext.delete(subject)
        }
        
        // 保存上下文
        do {
            try modelContext.save()
            logger.info("成功保存删除操作")
        } catch {
            logger.error("保存删除操作失败: \(error.localizedDescription)")
            alertMessage = "保存失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    /// 保存科目函数，用于保存新创建或编辑的科目信息。
    /// - Parameters:
    ///   - name: 科目名称。
    ///   - score: 科目满分。
    ///   - editing: 正在编辑的科目对象，如果为nil则表示创建新科目。
    private func save(name: String, score: Double, editing subject: Subject?) {
        if let subject = subject {
            // 编辑现有科目
            logger.info("编辑现有科目: \(subject.name)")
            subject.name = name
            subject.totalScore = score
            logger.info("成功编辑科目: \(subject.name), 新名称: \(name), 新分数: \(score)")
        } else {
            // 创建新科目
            logger.info("创建新科目，名称: \(name), 分数: \(score)")
            let newSubject = Subject(name: name, totalScore: score, orderIndex: subjects.count)
            modelContext.insert(newSubject)
            logger.info("成功创建新科目: \(name)")
        }
        // 关闭sheet
        isShowingSheet = false
    }
    
    /// 显示添加表单函数，用于显示添加新科目的表单。
    private func showAddSheet() {
        logger.info("显示添加科目表单")
        subjectToEdit = nil
        isShowingSheet = true
    }
    
    /// 触发数据完整性检查函数，用于手动清理异常数据。
    private func triggerDataIntegrityCheck() {
        logger.info("用户手动触发数据完整性检查")
        
        // 设置标志，让MainTabView在下次启动时执行检查
        UserDefaults.standard.set(true, forKey: "ShouldPerformDataIntegrityCheck")
        
        // 显示提示信息
        alertMessage = "数据完整性检查已启用。请重启应用以执行清理操作。"
        showingAlert = true
        
        logger.info("数据完整性检查标志已设置")
    }
}


// MARK: - Encapsulated Row View

/// [V21] 封装的科目行视图，用于在列表中显示单个科目的信息。
struct SubjectRow: View {
    /// 直接持有Subject对象，避免使用persistentModelID导致的闪退问题
    let subject: Subject
    
    init(subject: Subject) {
        self.subject = subject
    }
    
    /// 视图的主体部分
    var body: some View {
        // 使用HStack水平排列内容
        HStack {
            // 显示科目名称
            Text(subject.name)
                .font(.headline)
            // 添加弹性空间
            Spacer()
            // 显示科目满分
            Text("满分: \(subject.totalScore, specifier: "%.0f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        // 设置垂直内边距
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

// 预览提供者
#Preview("管理科目") {
    // [V21] 为了让预览能正常工作，我们需要一个模型容器。
    ManageSubjectsView()
        .modelContainer(for: Subject.self)
}
