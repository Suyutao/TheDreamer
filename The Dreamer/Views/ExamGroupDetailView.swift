//
//  ExamGroupDetailView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// 功能简介：
// ExamGroupDetailView 是考试组详情视图，提供以下功能：
// 1. 显示考试组基本信息（名称、学期、创建时间）
// 2. 显示考试组中所有考试的列表
// 3. 添加现有的单科考试到考试组
// 4. 从考试组中移除考试
// 5. 编辑考试组信息
// 6. 显示考试组统计信息（总分、平均分等）

import SwiftUI
import SwiftData

/// 考试组详情视图
struct ExamGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let examGroup: ExamGroup
    
    @Query private var allExams: [Exam]
    @State private var showingAddExamSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 考试组基本信息
                    examGroupInfoSection
                    
                    // 统计信息
                    if !examGroup.exams.isEmpty {
                        statisticsSection
                    }
                    
                    // 考试列表
                    examsSection
                }
                .padding()
            }
            .navigationTitle(examGroup.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("编辑信息") {
                            showingEditSheet = true
                        }
                        
                        Button("添加考试") {
                            showingAddExamSheet = true
                        }
                        
                        Divider()
                        
                        Button("删除考试组", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddExamSheet) {
                AddExamToGroupView(examGroup: examGroup, availableExams: availableExams)
            }
            .sheet(isPresented: $showingEditSheet) {
                EditExamGroupView(examGroup: examGroup)
            }
            .alert("删除考试组", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteExamGroup()
                }
            } message: {
                Text("删除考试组后，其中的考试将变为单科考试。此操作无法撤销。")
            }
        }
    }
    
    // MARK: - 视图组件
    
    private var examGroupInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("基本信息")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "学期", value: examGroup.semester)
                InfoRow(label: "创建时间", value: DateFormatter.localizedString(from: examGroup.createdDate, dateStyle: .medium, timeStyle: .short))
                InfoRow(label: "考试数量", value: "\(examGroup.exams.count) 场")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("统计信息")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                StatCard(title: "总分", value: String(format: "%.1f", totalScore), color: .blue)
                StatCard(title: "平均分", value: String(format: "%.1f", averageScore), color: .green)
                StatCard(title: "最高分", value: String(format: "%.1f", highestScore), color: .orange)
            }
        }
    }
    
    private var examsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("考试列表")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !availableExams.isEmpty {
                    Button("添加考试") {
                        showingAddExamSheet = true
                    }
                    .font(.caption)
                }
            }
            
            if examGroup.exams.isEmpty {
                EmptyStateView(
                    iconName: "doc.badge.plus",
                    title: "暂无考试",
                    message: "点击上方按钮添加考试到此考试组"
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(examGroup.exams.sorted(by: { $0.date > $1.date })) { exam in
                        ExamRowInGroupView(exam: exam) {
                            removeExamFromGroup(exam)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var availableExams: [Exam] {
        allExams.filter { $0.examGroup == nil }
    }
    
    private var totalScore: Double {
        examGroup.exams.reduce(0) { $0 + $1.score }
    }
    
    private var averageScore: Double {
        guard !examGroup.exams.isEmpty else { return 0 }
        return totalScore / Double(examGroup.exams.count)
    }
    
    private var highestScore: Double {
        examGroup.exams.map { $0.score }.max() ?? 0
    }
    
    // MARK: - 操作方法
    
    private func removeExamFromGroup(_ exam: Exam) {
        withAnimation {
            exam.examGroup = nil
            
            do {
                try modelContext.save()
                print("[\(Date())] 考试已从考试组中移除")
            } catch {
                print("[\(Date())] 移除考试时发生错误: \(error)")
            }
        }
    }
    
    private func deleteExamGroup() {
        // 将所有考试的examGroup设置为nil
        for exam in examGroup.exams {
            exam.examGroup = nil
        }
        
        // 删除考试组
        modelContext.delete(examGroup)
        
        do {
            try modelContext.save()
            print("[\(Date())] 考试组删除成功")
            dismiss()
        } catch {
            print("[\(Date())] 删除考试组时发生错误: \(error)")
        }
    }
}

// MARK: - 辅助视图

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ExamRowInGroupView: View {
    let exam: Exam
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exam.name)
                    .font(.headline)
                
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
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 预览

#Preview {
    ExamGroupDetailView(examGroup: ExamGroup(name: "期中考试", semester: "2024-2025学年上学期"))
}