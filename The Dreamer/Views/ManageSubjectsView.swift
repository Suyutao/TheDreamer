//
//  ManageSubjectsView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 导入SwiftUI框架用于构建用户界面
// 导入SwiftData框架用于数据持久化
// 导入OSLog框架用于日志记录
import SwiftUI
import SwiftData
import OSLog

// 定义ManageSubjectsView结构体，遵循View协议
struct ManageSubjectsView: View {
    // 创建日志对象
    private let logger = Logger(subsystem: "com.suyutao.The-Dreamer", category: "ManageSubjectsView")
    
    // 获取当前的模型上下文，用于数据操作
    @Environment(\.modelContext) private var modelContext
    // 获取dismiss环境值，用于关闭当前视图
    @Environment(\.dismiss) private var dismiss
    // 查询Subject对象，按orderIndex排序
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    
    // 状态变量，控制编辑科目表单是否显示
    @State private var isShowingSheet = false
    // 状态变量，保存正在编辑的科目对象
    @State private var subjectToEdit: Subject?
    // 状态变量，控制列表的编辑模式
    @State private var editMode: EditMode = .inactive
    // 状态变量，控制警告弹窗是否显示
    @State private var showingAlert = false
    // 状态变量，保存警告弹窗的消息内容
    @State private var alertMessage = ""

    // 视图的主体部分
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
                            // 使用HStack水平排列内容
                            HStack {
                                // 在编辑模式下显示移动按钮
                                if editMode.isEditing {
                                    // 使用VStack垂直排列移动按钮
                                    VStack {
                                        // 上移按钮
                                        Button(action: { moveUp(subject) }) { Image(systemName: "chevron.up") }
                                            // 当科目为第一个时禁用按钮
                                            .disabled(subject == subjects.first)
                                        // 下移按钮
                                        Button(action: { moveDown(subject) }) { Image(systemName: "chevron.down") }
                                            // 当科目为最后一个时禁用按钮
                                            .disabled(subject == subjects.last)
                                    }
                                    // 设置按钮样式为无边框
                                    .buttonStyle(.borderless)
                                }
                                // 导航链接到科目详情视图
                                NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                    // 显示科目行视图
                                    SubjectRow(subject: subject)
                                }
                            }
                        }
                        // 为列表添加删除功能
                        .onDelete(perform: deleteSubject)
                    }
                }
            }
            // 设置导航标题
            .navigationTitle("管理科目")
            // 设置工具栏内容
            .toolbar {
                // 取消按钮，用于关闭当前视图
                ToolbarItem(placement: .cancellationAction) { Button("完成") { dismiss() } }
                // 编辑按钮，用于切换编辑模式
                ToolbarItem(placement: .primaryAction) { EditButton() }
                // 添加按钮，用于添加新科目
                ToolbarItem(placement: .primaryAction) {
                    Button(action: showAddSheet) { Image(systemName: "plus") }
                        // 在编辑模式下隐藏添加按钮
                        .opacity(editMode.isEditing ? 0 : 1)
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
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Functions
    // 上移科目函数
    private func moveUp(_ subject: Subject) {
        logger.info("尝试上移科目: \(subject.name)")
        // 确保当前科目索引大于0
        guard let currentIndex = subjects.firstIndex(of: subject), currentIndex > 0 else { 
            logger.warning("无法上移科目 \(subject.name): 已经是第一个科目")
            return 
        }
        // 获取要交换的科目
        let subjectToSwap = subjects[currentIndex - 1]
        // 交换两个科目的orderIndex
        let tempOrder = subject.orderIndex
        subject.orderIndex = subjectToSwap.orderIndex
        subjectToSwap.orderIndex = tempOrder
        logger.info("成功上移科目: \(subject.name)")
    }

    // 下移科目函数
    private func moveDown(_ subject: Subject) {
        logger.info("尝试下移科目: \(subject.name)")
        // 确保当前科目索引小于科目总数
        guard let currentIndex = subjects.firstIndex(of: subject), currentIndex < subjects.count - 1 else { 
            logger.warning("无法下移科目 \(subject.name): 已经是最后一个科目")
            return 
        }
        // 获取要交换的科目
        let subjectToSwap = subjects[currentIndex + 1]
        // 交换两个科目的orderIndex
        let tempOrder = subject.orderIndex
        subject.orderIndex = subjectToSwap.orderIndex
        subjectToSwap.orderIndex = tempOrder
        logger.info("成功下移科目: \(subject.name)")
    }

    // 删除科目函数
    private func deleteSubject(at offsets: IndexSet) {
        logger.info("尝试删除科目，删除索引: \(offsets)")
        // 遍历要删除的索引集合并删除对应的科目
        offsets.forEach { 
            let subject = subjects[$0]
            logger.info("删除科目: \(subject.name)")
            modelContext.delete(subjects[$0]) 
        }
    }
    
    // 保存科目函数
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
    
    // 显示添加表单函数
    private func showAddSheet() {
        logger.info("显示添加科目表单")
        subjectToEdit = nil
        isShowingSheet = true
    }
}


// MARK: - Encapsulated Row View

/// [V21] 封装的科目行视图，用于在列表中显示单个科目的信息。
// 定义SubjectRow结构体，遵循View协议
struct SubjectRow: View {
    // 接收一个Subject对象
    let subject: Subject
    
    // 视图的主体部分
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
