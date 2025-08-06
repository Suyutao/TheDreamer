//
//  AddExamToGroupView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// 功能简介：
// AddExamToGroupView 用于将现有的单科考试添加到指定的考试组中
// 1. 显示所有可用的单科考试（examGroup为nil的考试）
// 2. 支持多选考试
// 3. 批量添加选中的考试到考试组
// 4. 提供搜索和筛选功能

import SwiftUI
import SwiftData

/// 添加考试到考试组视图
struct AddExamToGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let examGroup: ExamGroup
    let availableExams: [Exam]
    
    @State private var selectedExams: Set<Exam> = []
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if filteredExams.isEmpty {
                    EmptyStateView(
                        iconName: "doc.badge.plus",
                        title: searchText.isEmpty ? "暂无可用考试" : "未找到匹配的考试",
                        message: searchText.isEmpty ? "所有考试都已加入考试组，或者还没有创建任何考试" : "尝试使用其他关键词搜索"
                    )
                } else {
                    List {
                        ForEach(filteredExams) { exam in
                            ExamSelectionRow(
                                exam: exam,
                                isSelected: selectedExams.contains(exam)
                            ) {
                                toggleExamSelection(exam)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "搜索考试名称或科目")
                }
            }
            .navigationTitle("添加考试")
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
                    Button("添加 (\(selectedExams.count))") {
                        addSelectedExamsToGroup()
                    }
                    .disabled(selectedExams.isEmpty)
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var filteredExams: [Exam] {
        if searchText.isEmpty {
            return availableExams.sorted { $0.date > $1.date }
        } else {
            return availableExams.filter { exam in
                exam.name.localizedCaseInsensitiveContains(searchText) ||
                (exam.subject?.name.localizedCaseInsensitiveContains(searchText) ?? false)
            }.sorted { $0.date > $1.date }
        }
    }
    
    // MARK: - 操作方法
    
    private func toggleExamSelection(_ exam: Exam) {
        if selectedExams.contains(exam) {
            selectedExams.remove(exam)
        } else {
            selectedExams.insert(exam)
        }
    }
    
    private func addSelectedExamsToGroup() {
        withAnimation {
            for exam in selectedExams {
                exam.examGroup = examGroup
            }
            
            do {
                try modelContext.save()
                print("[\(Date())] 成功添加 \(selectedExams.count) 场考试到考试组")
                dismiss()
            } catch {
                print("[\(Date())] 添加考试到考试组时发生错误: \(error)")
            }
        }
    }
}

// MARK: - 考试选择行视图

struct ExamSelectionRow: View {
    let exam: Exam
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // 选择指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exam.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(exam.subject?.name ?? "未知科目")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(DateFormatter.localizedString(from: exam.date, dateStyle: .short, timeStyle: .none))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(exam.score, specifier: "%.1f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("/\(exam.subject?.totalScore ?? 0, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预览

#Preview {
    AddExamToGroupView(
        examGroup: ExamGroup(name: "期中考试", semester: "2024-2025学年上学期"),
        availableExams: []
    )
}