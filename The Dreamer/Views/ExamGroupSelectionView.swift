//
//  ExamGroupSelectionView.swift
//  The Dreamer
//
//  Created by AI Assistant
//
// 考试组选择界面，用于在AddDataView中选择或创建考试组

import SwiftUI
import SwiftData

struct ExamGroupSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\ExamGroup.createdDate, order: .reverse)]) 
    private var examGroups: [ExamGroup]
    @Query private var allExams: [Exam]
    
    // 支持两种模式：单选模式和批量模式
    @Binding var selectedGroup: ExamGroup?
    let selectedExamIds: Set<Exam.ID>?
    let onComplete: (() -> Void)?
    
    // 控制添加新考试组的Sheet
    @State private var showingAddGroup = false
    
    // 判断是否为批量模式
    private var isBatchMode: Bool {
        selectedExamIds != nil
    }
    
    // 单选模式初始化方法（原有功能）
    init(selectedGroup: Binding<ExamGroup?>) {
        self._selectedGroup = selectedGroup
        self.selectedExamIds = nil
        self.onComplete = nil
    }
    
    // 批量模式初始化方法（新功能）
    init(selectedExamIds: Set<Exam.ID>, onComplete: @escaping () -> Void) {
        self._selectedGroup = .constant(nil)
        self.selectedExamIds = selectedExamIds
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationView {
            List {
                // "单科考试" 选项（仅在单选模式下显示）
                if !isBatchMode {
                    Button(action: {
                        selectedGroup = nil
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("单科考试")
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedGroup == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                if !examGroups.isEmpty {
                    Section(isBatchMode ? "选择考试组" : "考试组") {
                        ForEach(examGroups) { group in
                            Button(action: {
                                if isBatchMode {
                                    addExamsToGroup(group)
                                } else {
                                    selectedGroup = group
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "folder")
                                        .foregroundColor(.orange)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(group.name)
                                            .foregroundColor(.primary)
                                        Text(group.semester)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        if isBatchMode {
                                            Text("\(group.exams.count) 场考试")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    if !isBatchMode && selectedGroup?.id == group.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    } else if isBatchMode {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingAddGroup = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("添加新考试组")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // 底部信息（仅在批量模式下显示）
                if isBatchMode, let selectedExamIds = selectedExamIds {
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("已选择 \(selectedExamIds.count) 个考试")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(isBatchMode ? "添加到考试组" : "选择考试组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            if isBatchMode {
                AddExamGroupView { newExamGroup in
                    addExamsToGroup(newExamGroup)
                }
            } else {
                AddExamGroupView()
            }
        }
    }
    
    // MARK: - 批量操作方法
    
    /// 将选中的考试添加到指定考试组
    private func addExamsToGroup(_ examGroup: ExamGroup) {
        guard let selectedExamIds = selectedExamIds else { return }
        
        let selectedExams = allExams.filter { selectedExamIds.contains($0.id) }
        
        for exam in selectedExams {
            // 如果考试已经在其他考试组中，先移除
            if let currentGroup = exam.examGroup {
                currentGroup.exams.removeAll { $0.id == exam.id }
            }
            
            // 添加到新的考试组
            exam.examGroup = examGroup
            if !examGroup.exams.contains(where: { $0.id == exam.id }) {
                examGroup.exams.append(exam)
            }
        }
        
        do {
            try modelContext.save()
            print("[\(Date())] 成功将 \(selectedExams.count) 个考试添加到考试组: \(examGroup.name)")
            
            // 完成操作
            onComplete?()
            dismiss()
        } catch {
            print("[\(Date())] 添加考试到考试组时发生错误: \(error)")
        }
    }
}

// MARK: - 添加考试组视图
struct AddExamGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var semester = ""
    
    // 可选的回调，用于批量模式
    let onExamGroupCreated: ((ExamGroup) -> Void)?
    
    // 初始化方法
    init(onExamGroupCreated: ((ExamGroup) -> Void)? = nil) {
        self.onExamGroupCreated = onExamGroupCreated
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("考试组信息")) {
                    TextField("考试组名称", text: $groupName)
                    TextField("学期", text: $semester)
                        .placeholder(when: semester.isEmpty) {
                            Text("例如：2024-2025学年第一学期")
                                .foregroundColor(.secondary)
                        }
                }
            }
            .navigationTitle("添加考试组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        saveExamGroup()
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                             semester.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveExamGroup() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSemester = semester.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty && !trimmedSemester.isEmpty else { return }
        
        do {
            let newGroup = ExamGroup(name: trimmedName, semester: trimmedSemester)
            modelContext.insert(newGroup)
            try modelContext.save()
            print("\(Date()) [AddExamGroupView] 成功创建考试组：\(trimmedName)")
            
            // 如果有回调，调用回调并传递新创建的考试组
            onExamGroupCreated?(newGroup)
            
            dismiss()
        } catch {
            print("\(Date()) [AddExamGroupView] 创建考试组失败：\(error.localizedDescription)")
        }
    }
}

// MARK: - 扩展：占位符支持
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
#Preview("考试组选择") {
    ExamGroupSelectionView(selectedGroup: .constant(nil))
        .modelContainer(for: [ExamGroup.self])
}

#Preview("添加考试组") {
    AddExamGroupView()
        .modelContainer(for: [ExamGroup.self])
}