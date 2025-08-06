//
//  ExamGroupManagementView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// 功能简介：
// ExamGroupManagementView 是考试组管理的主视图，提供以下功能：
// 1. 显示所有考试组列表
// 2. 查看每个考试组的详细信息（包含的考试数量、总分等）
// 3. 添加新的考试组
// 4. 编辑现有考试组
// 5. 删除考试组（包括空考试组的自动清理）
// 6. 管理考试组中的考试（添加、移除考试）

import SwiftUI
import SwiftData

/// 考试组管理主视图
struct ExamGroupManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExamGroup.createdDate, order: .reverse) private var examGroups: [ExamGroup]
    @Query private var allExams: [Exam]
    
    @State private var showingAddExamGroup = false
    @State private var selectedExamGroup: ExamGroup?
    @State private var showingExamGroupDetail = false
    
    var body: some View {
        NavigationView {
            VStack {
                if examGroups.isEmpty {
                    EmptyStateView(
                        iconName: "folder.badge.plus",
                        title: "暂无考试组",
                        message: "创建考试组来组织多科考试，便于统一管理和分析"
                    )
                } else {
                    List {
                        ForEach(examGroups) { examGroup in
                            ZStack {
                                Button(action: {
                                    selectedExamGroup = examGroup
                                    showingExamGroupDetail = true
                                }) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                ExamGroupRowView(examGroup: examGroup) {
                                    selectedExamGroup = examGroup
                                    showingExamGroupDetail = true
                                }
                                .contentShape(Rectangle())
                            }
                        }
                        .onDelete(perform: deleteExamGroups)
                    }
                }
            }
            .navigationTitle("考试组管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("添加") {
                        showingAddExamGroup = true
                    }
                }
            }
            .sheet(isPresented: $showingAddExamGroup) {
                AddExamGroupView()
            }
            .sheet(isPresented: $showingExamGroupDetail) {
                if let examGroup = selectedExamGroup {
                    ExamGroupDetailView(examGroup: examGroup)
                }
            }
        }
    }
    
    // MARK: - 删除考试组
    
    private func deleteExamGroups(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let examGroup = examGroups[index]
                
                // 将考试组中的所有考试的examGroup设置为nil（变为单科考试）
                for exam in examGroup.exams {
                    exam.examGroup = nil
                }
                
                // 删除考试组
                modelContext.delete(examGroup)
            }
            
            do {
                try modelContext.save()
                print("[\(Date())] 考试组删除成功")
            } catch {
                print("[\(Date())] 删除考试组时发生错误: \(error)")
            }
        }
    }
}

// MARK: - 考试组行视图

struct ExamGroupRowView: View {
    let examGroup: ExamGroup
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(examGroup.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(examGroup.semester)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(examGroup.exams.count) 场考试")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !examGroup.exams.isEmpty {
                            Spacer()
                            Text("总分: \(totalScore, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
    
    private var totalScore: Double {
        examGroup.exams.reduce(0) { $0 + $1.score }
    }
}

// MARK: - 预览

#Preview {
    ExamGroupManagementView()
}