//
//  ManageSubjectsView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

struct ManageSubjectsView: View {
    // =======================================================================
    // MARK: - Properties & State
    // =======================================================================
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // [V21] 使用 @Query 动态获取所有科目，并按名称排序。
    @Query(sort: \Subject.name) private var subjects: [Subject]
    
    // [V21] 用于控制添加/编辑工作表的显示状态。
    @State private var isShowingSheet = false
    // [V21] 用于判断是添加新科目还是编辑现有科目。
    // [V21] 如果为nil，则为添加；如果不为nil，则为编辑。
    @State private var subjectToEdit: Subject?

    // =======================================================================
    // MARK: - Main Body
    // =======================================================================
    
    var body: some View {
        NavigationView {
            List {
                // [V21] 遍历查询到的所有科目，为每个科目生成一行。
                ForEach(subjects) { subject in
                    SubjectRow(subject: subject)
                        .onTapGesture {
                            // [V21] 点击某一行时，设置要编辑的科目并弹出工作表。
                            subjectToEdit = subject
                            isShowingSheet = true
                        }
                }
                .onDelete(perform: deleteSubject)
            }
            .navigationTitle("管理科目")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    // [V21] 添加按钮
                    Button(action: {
                        // [V21] 点击添加时，将 subjectToEdit 设为 nil，表示是新建操作。
                        subjectToEdit = nil
                        isShowingSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // [V21] 使用 .sheet 来呈现添加/编辑界面。
            // [V21] isPresented 绑定到一个State变量，当它为true时，工作表弹出。
            .sheet(isPresented: $isShowingSheet) {
                // [V21] 将 subjectToEdit 传入工作表视图。
                SubjectEditView(subject: subjectToEdit)
            }
        }
    }
    
    // =======================================================================
    // MARK: - Functions
    // =======================================================================
    
    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subjectToDelete = subjects[index]
            modelContext.delete(subjectToDelete)
        }
    }
}

// =======================================================================
// MARK: - Encapsulated Row View
// =======================================================================

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

// =======================================================================
// MARK: - Add/Edit Sheet View
// =======================================================================

/// [V21] 用于添加或编辑科目的工作表视图。
struct SubjectEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // [V21] 接收传入的科目。如果为nil，则是添加模式。
    let subject: Subject?
    
    @State private var name: String = ""
    @State private var totalScore: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("科目信息")) {
                    TextField("科目名称", text: $name)
                    TextField("满分", text: $totalScore)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(subject == nil ? "添加新科目" : "编辑科目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                }
            }
            // [V21] 当视图出现时，根据是添加还是编辑模式，初始化UI状态。
            .onAppear(perform: setupInitialState)
        }
    }
    
    private func setupInitialState() {
        if let subject = subject {
            // [V21] 编辑模式：用现有科目的数据填充表单。
            name = subject.name
            totalScore = "\(subject.totalScore)"
        }
    }
    
    private func save() {
        guard !name.isEmpty, let scoreValue = Double(totalScore) else {
            // [V21] 在真实应用中，这里应该有用户提示。
            print("信息不完整或格式错误")
            return
        }
        
        if let subject = subject {
            // [V21] 编辑模式：更新现有科目的属性。
            subject.name = name
            subject.totalScore = scoreValue
        } else {
            // [V21] 添加模式：创建一个新的科目实例并插入数据库。
            let newSubject = Subject(name: name, totalScore: scoreValue)
            modelContext.insert(newSubject)
        }
        
        dismiss()
    }
}


// =======================================================================
// MARK: - Preview
// =======================================================================

#Preview {
    // [V21] 为了让预览能正常工作，我们需要一个模型容器。
    ManageSubjectsView()
        .modelContainer(for: Subject.self, inMemory: true)
}
