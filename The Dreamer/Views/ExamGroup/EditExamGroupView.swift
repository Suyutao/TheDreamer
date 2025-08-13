//
//  EditExamGroupView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// 功能简介：
// EditExamGroupView 用于编辑现有考试组的信息
// 1. 修改考试组名称
// 2. 修改考试组学期
// 3. 表单验证
// 4. 保存更改

import SwiftUI
import SwiftData

/// 编辑考试组视图
struct EditExamGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let examGroup: ExamGroup
    
    @State private var name: String
    @State private var semester: String
    
    init(examGroup: ExamGroup) {
        self.examGroup = examGroup
        self._name = State(initialValue: examGroup.name)
        self._semester = State(initialValue: examGroup.semester)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("考试组信息") {
                    TextField("考试组名称", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("学期", text: $semester)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Text("创建时间: \(DateFormatter.localizedString(from: examGroup.createdDate, dateStyle: .medium, timeStyle: .short))")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text("包含考试: \(examGroup.exams.count) 场")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } header: {
                    Text("其他信息")
                }
            }
            .navigationTitle("编辑考试组")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !semester.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (name != examGroup.name || semester != examGroup.semester)
    }
    
    // MARK: - 操作方法
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSemester = semester.trimmingCharacters(in: .whitespacesAndNewlines)
        
        examGroup.name = trimmedName
        examGroup.semester = trimmedSemester
        
        do {
            try modelContext.save()
            print("[\(Date())] 考试组信息更新成功")
            dismiss()
        } catch {
            print("[\(Date())] 更新考试组信息时发生错误: \(error)")
        }
    }
}

// MARK: - 预览

#Preview {
    EditExamGroupView(examGroup: ExamGroup(name: "期中考试", semester: "2024-2025学年上学期"))
}