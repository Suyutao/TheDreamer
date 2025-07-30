//
//  ManageSubjectsView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

struct ManageSubjectsView: View {
    // MARK: - Properties & State
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // [V23] 修正：为了手动排序，我们需要移除 @Query 的自动排序。
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    
    @State private var isShowingSheet = false
    @State private var subjectToEdit: Subject?
    
    // [V23] 用于控制列表的编辑模式
    @State private var editMode: EditMode = .inactive

    // MARK: - Main Body
    var body: some View {
        NavigationView {
            ZStack {
                if subjects.isEmpty && !editMode.isEditing {
                    EmptyStateView(
                        title: "尚无科目",
                        message: "点击右上角的 '+' 按钮来创建你的第一个学习科目吧。"
                    )
                    // [V27] 解决方案：在分支内部应用标题
                    .navigationTitle("管理科目")
                    .navigationBarTitleDisplayMode(.inline) // [V27] 保持标题样式一致
                } else {
                    List {
                        ForEach(subjects) { subject in
                            NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                SubjectRow(subject: subject)
                            }
                        }
                        .onMove(perform: moveSubject)
                        .onDelete(perform: deleteSubject)
                    }
                    // [V27] 解决方案：在分支内部应用标题
                    .navigationTitle("管理科目")
                    .navigationBarTitleDisplayMode(.inline) // [V27] 保持标题样式一致
                }
            }
            // [V27] 移除在ZStack或Group上的旧标题修饰符
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    // [V22] EditButton 会自动处理 editMode 的切换
                    // [V27] 恢复使用标准的、可本地化的EditButton
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: showAddSheet) {
                        Image(systemName: "plus")
                    }
                    .opacity(editMode.isEditing ? 0 : 1)
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                // [V25] 在这里为 SubjectEditView 提供 onSave 的实现
                SubjectEditView(subject: subjectToEdit) { name, totalScore in
                    saveSubject(name: name, totalScore: totalScore)
                }
            }
            // [V22] 将 editMode 状态绑定到环境中，让 EditButton 和 List 联动
            .environment(\.editMode, $editMode)
        }
    }
    
    // MARK: - Functions
    
    private func saveSubject(name: String, totalScore: Double) {
            // [V25] 所有的保存逻辑现在都集中在这里
        if let subjectToEdit = subjectToEdit {
                // 编辑模式
            subjectToEdit.name = name
            subjectToEdit.totalScore = totalScore
        } else {
                // 添加模式
            let newIndex = (subjects.map(\.orderIndex).max() ?? -1) + 1
            let newSubject = Subject(
                name: name,
                totalScore: totalScore,
                orderIndex: newIndex
            )
            modelContext.insert(newSubject)
        }
            // [V25] SwiftData 会自动处理保存，我们不需要手动调用 modelContext.save()
    }
    
    private func showAddSheet() {
        subjectToEdit = nil
        isShowingSheet = true
    }
    
    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subjectToDelete = subjects[index]
            modelContext.delete(subjectToDelete)
        }
    }
    
    private func moveSubject(from source: IndexSet, to destination: Int) {
            // [V22] 这是手动排序的核心逻辑
        var revisedSubjects = subjects
        revisedSubjects.move(fromOffsets: source, toOffset: destination)
        
            // [V22] 更新 orderIndex 以持久化排序
        for (index, subject) in revisedSubjects.enumerated() {
            subject.orderIndex = index
        }
    }
}


// MARK: - Encapsulated Row View

/// [V21] 封装的科目行视图，用于在列表中显示单个科目的信息。
struct SubjectRow: View {
    let subject: Subject
    
    var body: some View {
        HStack {
            Text(subject.name)
                .font(.headline)
            Spacer()
            Text("满分: \(subject.totalScore, specifier: "%.0f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    // [V21] 为了让预览能正常工作，我们需要一个模型容器。
    ManageSubjectsView()
        .modelContainer(for: Subject.self, inMemory: true)
}
