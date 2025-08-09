//
//  SubjectDataView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 8/9/25.
//

import SwiftUI
import SwiftData

/// 显示单个科目所有数据的视图
struct SubjectDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let subject: Subject
    
    // 获取该科目的所有考试，按日期倒序排序
    @Query private var allExams: [Exam]
    
    // 状态变量
    @State private var addableDataType: AddableDataType? = nil
    @State private var showingAddDataSheet = false
    @State private var showingDeleteAlert = false
    @State private var examToDelete: Exam? = nil
    
    // MARK: - 撤销机制相关状态
    @StateObject private var undoManager = CustomUndoManager()
    @State private var showingUndoToast = false
    @State private var undoMessage = ""
    @State private var deletedExams: [Exam] = []
    
    // 计算属性：过滤出该科目的考试
    private var subjectExams: [Exam] {
        allExams.filter { $0.subject?.id == subject.id }
            .sorted { $0.date > $1.date }
    }
    
    init(subject: Subject) {
        self.subject = subject
        // 设置查询以获取所有考试
        self._allExams = Query(
            filter: #Predicate<Exam> { _ in true },
            sort: [SortDescriptor(\Exam.date, order: .reverse)]
        )
    }
    
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
    
    var body: some View {
        ZStack {
            if subjectExams.isEmpty {
                // 显示空状态视图
                EmptyStateView(
                    iconName: "tray.fill",
                    title: "暂无\(subject.name)成绩记录",
                    message: "点击右上角的 \"添加数据\" 按钮，开始记录\(subject.name)的第一次成绩吧！"
                )
            } else {
                // 显示考试列表
                List {
                    ForEach(subjectExams) { exam in
                        NavigationLink(destination: ExamDetailView(exam: exam)) {
                            ExamRowView(exam: exam)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteSingleExam(exam)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indices in
                        // 处理批量删除
                        let examsToDelete = indices.map { subjectExams[$0] }
                        if examsToDelete.count == 1 {
                            examToDelete = examsToDelete.first
                            showingDeleteAlert = true
                        } else {
                            // 批量删除多个考试
                            for exam in examsToDelete {
                                modelContext.delete(exam)
                            }
                            try? modelContext.save()
                        }
                    }
                }
            }
        }
        .navigationTitle("\(subject.name) - 所有数据")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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
        // 添加数据界面的弹窗
        .sheet(isPresented: $showingAddDataSheet) {
            AddDataView(
                dataType: $addableDataType,
                examToEdit: nil,
                preselectedSubject: subject
            )
            .environment(\.modelContext, modelContext)
        }
        // 删除确认对话框
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let exam = examToDelete {
                    deleteSingleExam(exam)
                    examToDelete = nil
                }
            }
        } message: {
            Text("确定要删除这个考试记录吗？此操作无法撤销。")
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
    }
}