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
    
    @Binding var selectedGroup: ExamGroup?
    
    // 控制添加新考试组的Sheet
    @State private var showingAddGroup = false
    
    var body: some View {
        NavigationView {
            List {
                // "单科考试" 选项
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
                
                if !examGroups.isEmpty {
                    Section("考试组") {
                        ForEach(examGroups) { group in
                            Button(action: {
                                selectedGroup = group
                                dismiss()
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
                                    }
                                    Spacer()
                                    if selectedGroup?.id == group.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
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
            }
            .navigationTitle("选择考试组")
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
            AddExamGroupView()
        }
    }
}

// MARK: - 添加考试组视图
struct AddExamGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var semester = ""
    
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