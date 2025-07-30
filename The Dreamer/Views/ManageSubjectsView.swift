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
    
    // [V30] 回归本源：让@Query负责排序。这是最可靠的数据来源。
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    
    @State private var isShowingSheet = false
    @State private var subjectToEdit: Subject?
    @State private var editMode: EditMode = .inactive

    // MARK: - Main Body
    var body: some View {
        NavigationView {
            ZStack {
                // [V30] 逻辑简化：UI直接由@Query驱动，不再有中间状态。
                if subjects.isEmpty {
                    EmptyStateView(
                        title: "尚无科目",
                        message: "点击右上角的 '+' 按钮来创建你的第一个学习科目吧。"
                    )
                    .navigationTitle("管理科目")
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    List {
                        // [V30] 直接遍历@Query的结果
                        ForEach(subjects) { subject in
                            HStack {
                                // [V30] 在编辑模式下，显示排序控件
                                if editMode.isEditing {
                                    VStack {
                                        // 上移按钮
                                        Button(action: { moveUp(subject) }) {
                                            Image(systemName: "chevron.up")
                                        }
                                        .disabled(subject == subjects.first) // 第一个不能上移
                                        
                                        // 下移按钮
                                        Button(action: { moveDown(subject) }) {
                                            Image(systemName: "chevron.down")
                                        }
                                        .disabled(subject == subjects.last) // 最后一个不能下移
                                    }
                                    .buttonStyle(.borderless) // 移除按钮的默认样式
                                    .padding(.trailing)
                                }
                                
                                NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                    SubjectRow(subject: subject)
                                }
                            }
                        }
                        .onDelete(perform: deleteSubject)
                        // [V30] 彻底移除 .onMove
                    }
                    .navigationTitle("管理科目")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
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
                SubjectEditView(subject: subjectToEdit) { name, totalScore in
                    saveSubject(name: name, totalScore: totalScore)
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    // MARK: - Functions
    private func moveUp(_ subject: Subject) {
        guard let currentIndex = subjects.firstIndex(of: subject), currentIndex > 0 else { return }
        let previousIndex = currentIndex - 1
        
        // 交换 orderIndex
        let subjectToSwap = subjects[previousIndex]
        let tempOrderIndex = subject.orderIndex
        subject.orderIndex = subjectToSwap.orderIndex
        subjectToSwap.orderIndex = tempOrderIndex
    }
    
    private func moveDown(_ subject: Subject) {
        guard let currentIndex = subjects.firstIndex(of: subject), currentIndex < subjects.count - 1 else { return }
        let nextIndex = currentIndex + 1
        
        // 交换 orderIndex
        let subjectToSwap = subjects[nextIndex]
        let tempOrderIndex = subject.orderIndex
        subject.orderIndex = subjectToSwap.orderIndex
        subjectToSwap.orderIndex = tempOrderIndex
    }
    
    private func saveSubject(name: String, totalScore: Double) {
        if let subjectToEdit = subjectToEdit {
            subjectToEdit.name = name
            subjectToEdit.totalScore = totalScore
        } else {
            let newIndex = (subjects.map(\.orderIndex).max() ?? -1) + 1
            let newSubject = Subject(name: name, totalScore: totalScore, orderIndex: newIndex)
            modelContext.insert(newSubject)
        }
    }
    
    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subjectToDelete = subjects[index]
            modelContext.delete(subjectToDelete)
        }
    }
    
    private func showAddSheet() {
        subjectToEdit = nil
        isShowingSheet = true
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
