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
    
    /// 状态变量，控制重复科目合并确认弹窗是否显示。
    @State private var showingDuplicateAlert = false
    
    /// 状态变量，保存待合并的重复科目信息。
    @State private var duplicateSubjects: [String: [Subject]] = [:]
    
    /// 状态变量，保存待保存的新科目信息（用于重名检查后的保存）。
    @State private var pendingSave: (name: String, score: Double, subject: Subject?)?
    
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
                
                // 根据编辑模式显示不同的按钮
                #if os(iOS)
                if editMode.isEditing {
                    // 编辑模式：显示添加和数据清理按钮
                    ToolbarItem(placement: .primaryAction) {
                        HStack {
                            Button(action: triggerDataIntegrityCheck) {
                                Image(systemName: "trash.circle")
                            }
                            Button(action: showAddSheet) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                } else {
                    // 非编辑模式：只显示编辑按钮
                    ToolbarItem(placement: .primaryAction) { EditButton() }
                }
                #else
                // macOS版本保持原有逻辑
                ToolbarItem(placement: .secondaryAction) {
                    Button(action: triggerDataIntegrityCheck) {
                        Image(systemName: "trash.circle")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: showAddSheet) { Image(systemName: "plus") }
                }
                #endif
            }
            // 设置表单页面
            .sheet(isPresented: $isShowingSheet) {
                SubjectEditView(subject: subjectToEdit, onSave: save)
            }
            // 设置警告弹窗
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("提醒"), message: Text(alertMessage), dismissButton: .default(Text("好")))
            }
            // 设置重复科目合并确认弹窗
            .alert("发现重复科目", isPresented: $showingDuplicateAlert) {
                Button("取消", role: .cancel) {
                    pendingSave = nil
                }
                Button("合并重复科目") {
                    performDuplicateMerge()
                }
                Button("仍然保存") {
                    performPendingSave()
                }
            } message: {
                Text(buildDuplicateAlertMessage())
            }
            // 设置编辑模式环境值
            #if os(iOS)
            .environment(\.editMode, $editMode)
            #endif
            .onAppear {
                checkForDuplicateSubjects()
            }
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
        
        // 先将所有科目的orderIndex设置为临时值，避免唯一性约束冲突
        for (index, subject) in reorderedSubjects.enumerated() {
            subject.orderIndex = index + 1000 // 使用临时的大数值
        }
        
        // 保存临时状态
        do {
            try modelContext.save()
        } catch {
            logger.error("保存临时排序状态失败: \(error.localizedDescription)")
            return
        }
        
        // 再将orderIndex设置为正确的值
        for (index, subject) in reorderedSubjects.enumerated() {
            subject.orderIndex = index
            logger.info("更新科目 \(subject.name) 的orderIndex为: \(index)")
        }
        
        // 保存最终状态
        do {
            try modelContext.save()
            logger.info("完成拖动排序")
        } catch {
            logger.error("保存最终排序状态失败: \(error.localizedDescription)")
        }
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
        // 检查是否存在重名科目（排除正在编辑的科目本身）
        let duplicates = subjects.filter { $0.name == name && $0 != subject }
        
        if !duplicates.isEmpty {
            // 发现重名科目，保存待处理信息并显示确认弹窗
            pendingSave = (name: name, score: score, subject: subject)
            duplicateSubjects = [name: duplicates]
            showingDuplicateAlert = true
            return
        }
        
        // 没有重名，直接保存
        performActualSave(name: name, score: score, editing: subject)
    }
    
    /// 执行实际的保存操作
    /// - Parameters:
    ///   - name: 科目名称
    ///   - score: 科目满分
    ///   - editing: 正在编辑的科目对象
    private func performActualSave(name: String, score: Double, editing subject: Subject?) {
        if let subject = subject {
            // 编辑现有科目
            logger.info("编辑现有科目: \(subject.name)")
            subject.name = name
            subject.totalScore = score
            // 更新时间戳
            subject.markAsUpdated()
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
    
    // MARK: - 重复科目处理方法
    
    /// 检查是否存在重复科目
    private func checkForDuplicateSubjects() {
        let subjectNames = subjects.map { $0.name }
        let duplicateNames = Dictionary(grouping: subjectNames, by: { $0 })
            .filter { $1.count > 1 }
            .keys
        
        if !duplicateNames.isEmpty {
            logger.info("发现重复科目: \(duplicateNames.joined(separator: ", "))")
            
            // 构建重复科目字典
            var duplicates: [String: [Subject]] = [:]
            for name in duplicateNames {
                duplicates[name] = subjects.filter { $0.name == name }
            }
            
            duplicateSubjects = duplicates
            
            // 显示合并提示（仅在首次发现时）
            if !UserDefaults.standard.bool(forKey: "HasShownDuplicateWarning") {
                alertMessage = "检测到重复的科目名称。建议合并这些重复科目以避免数据混乱。您可以在科目管理界面中处理这些重复项。"
                showingAlert = true
                UserDefaults.standard.set(true, forKey: "HasShownDuplicateWarning")
            }
        }
    }
    
    /// 构建重复科目弹窗消息
    private func buildDuplicateAlertMessage() -> String {
        guard let pending = pendingSave,
              let duplicates = duplicateSubjects[pending.name] else {
            return "发现重复科目"
        }
        
        var message = "科目名称 '\(pending.name)' 已存在 \(duplicates.count) 个重复项：\n\n"
        
        for (index, duplicate) in duplicates.enumerated() {
            message += "\(index + 1). 满分: \(String(format: "%.0f", duplicate.totalScore))\n"
            message += "   考试数量: \(duplicate.exams.count)\n"
            message += "   练习数量: \(duplicate.practiceCollections.count)\n\n"
        }
        
        message += "您可以选择合并这些重复科目，或者仍然保存新科目。"
        return message
    }
    
    /// 执行重复科目合并
    private func performDuplicateMerge() {
        guard let pending = pendingSave,
              let duplicates = duplicateSubjects[pending.name] else {
            pendingSave = nil
            return
        }
        
        logger.info("开始合并重复科目: \(pending.name)")
        
        // 选择第一个科目作为主科目，将其他科目的数据合并到它上面
        let primarySubject = duplicates[0]
        let subjectsToMerge = Array(duplicates.dropFirst())
        
        // 更新主科目的信息（使用新的满分值）
        primarySubject.totalScore = pending.score
        // 更新时间戳
        primarySubject.markAsUpdated()
        
        // 合并其他科目的数据到主科目
        for subjectToMerge in subjectsToMerge {
            // 转移考试数据
            for exam in subjectToMerge.exams {
                exam.subject = primarySubject
            }
            
            // 转移练习数据
            for practice in subjectToMerge.practiceCollections {
                practice.subject = primarySubject
            }
            
            // 转移模板数据
            for template in subjectToMerge.paperTemplates {
                template.subject = primarySubject
            }
            
            // 删除被合并的科目
            modelContext.delete(subjectToMerge)
            logger.info("删除重复科目: \(subjectToMerge.name)")
        }
        
        // 保存更改
        do {
            try modelContext.save()
            logger.info("成功合并重复科目: \(pending.name)")
            alertMessage = "已成功合并重复科目 '\(pending.name)'。"
            showingAlert = true
        } catch {
            logger.error("合并重复科目失败: \(error.localizedDescription)")
            alertMessage = "合并失败：\(error.localizedDescription)"
            showingAlert = true
        }
        
        // 清理状态
        pendingSave = nil
        duplicateSubjects.removeAll()
        isShowingSheet = false
    }
    
    /// 执行待保存操作（忽略重复检查）
    private func performPendingSave() {
        guard let pending = pendingSave else { return }
        
        logger.info("用户选择忽略重复检查，继续保存科目: \(pending.name)")
        performActualSave(name: pending.name, score: pending.score, editing: pending.subject)
        
        // 清理状态
        pendingSave = nil
        duplicateSubjects.removeAll()
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
