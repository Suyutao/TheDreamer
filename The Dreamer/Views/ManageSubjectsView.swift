//
//  ManageSubjectsView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

struct ManageSubjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Subject.orderIndex) private var subjects: [Subject]
    
    @State private var isShowingSheet = false
    @State private var subjectToEdit: Subject?
    @State private var editMode: EditMode = .inactive
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                if subjects.isEmpty {
                    EmptyStateView(
                        iconName: "books.vertical.fill",
                        title: "尚无科目",
                        message: "点击右上角的 '+' 按钮来创建你的第一个学习科目")
                } else {
                    List {
                        ForEach(subjects) { subject in
                            HStack {
                                if editMode.isEditing {
                                    VStack {
                                        Button(action: { moveUp(subject) }) { Image(systemName: "chevron.up") }
                                            .disabled(subject == subjects.first)
                                        Button(action: { moveDown(subject) }) { Image(systemName: "chevron.down") }
                                            .disabled(subject == subjects.last)
                                    }
                                    .buttonStyle(.borderless)
                                }
                                NavigationLink(destination: SubjectDetailView(subject: subject)) {
                                    SubjectRow(subject: subject)
                                }
                            }
                        }
                        .onDelete(perform: deleteSubject)
                    }
                }
            }
            .navigationTitle("管理科目")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("完成") { dismiss() } }
                ToolbarItem(placement: .primaryAction) { EditButton() }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: showAddSheet) { Image(systemName: "plus") }
                        .opacity(editMode.isEditing ? 0 : 1)
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                SubjectEditView(subject: subjectToEdit, onSave: save)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("提醒"), message: Text(alertMessage), dismissButton: .default(Text("好")))
            }
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Functions
    private func moveUp(_ subject: Subject) {
        guard let currentIndex = subjects.firstIndex(of: subject), currentIndex > 0 else { return }
        let subjectToSwap = subjects[currentIndex - 1]
        let tempOrder = subject.orderIndex
        subject.orderIndex = subjectToSwap.orderIndex
        subjectToSwap.orderIndex = tempOrder
    }

    private func moveDown(_ subject: Subject) {
        guard let currentIndex = subjects.firstIndex(of: subject), currentIndex < subjects.count - 1 else { return }
        let subjectToSwap = subjects[currentIndex + 1]
        let tempOrder = subject.orderIndex
        subject.orderIndex = subjectToSwap.orderIndex
        subjectToSwap.orderIndex = tempOrder
    }

    private func deleteSubject(at offsets: IndexSet) {
        offsets.forEach { modelContext.delete(subjects[$0]) }
    }
    
    private func save(name: String, score: Double, editing subject: Subject?) {
        if let subject = subject {
            // 编辑现有科目
            subject.name = name
            subject.totalScore = score
        } else {
            // 创建新科目
            let newSubject = Subject(name: name, totalScore: score, orderIndex: subjects.count)
            modelContext.insert(newSubject)
        }
        // 关闭sheet
        isShowingSheet = false
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

#Preview("管理科目") {
    // [V21] 为了让预览能正常工作，我们需要一个模型容器。
    ManageSubjectsView()
        .modelContainer(for: Subject.self)
}
