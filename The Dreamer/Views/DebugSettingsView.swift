//
//  DebugSettingsView.swift
//  The Dreamer
//
//  Created by AI Assistant on 8/6/25.
//

import SwiftUI
import SwiftData

/// 调试设置视图
/// 包含所有调试相关的功能，如清除数据、重置设置等
/// 所有危险操作都需要额外的安全验证
struct DebugSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 安全验证相关状态
    @State private var confirmationText = ""
    @State private var showingDeleteConfirmation = false
    @State private var showValidationError = false
    
    // 定义验证文本常量
    private let deleteConfirmationKeyword = "确认删除所有数据"
    
    var body: some View {
        NavigationStack {
            List {
                // 危险操作分组
                Section("危险操作") {
                    // 清除所有数据（带安全验证）
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("清除所有数据")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text("此操作将永久删除所有科目、考试、练习等数据，且无法恢复。")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 安全验证输入框
                        VStack(alignment: .leading, spacing: 8) {
                            Text("请输入以下内容进行验证：")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\"\(deleteConfirmationKeyword)\"")
                                .font(.caption.monospaced())
                                .foregroundColor(.primary)
                                
                            TextField("输入验证文本", text: $confirmationText)
                                .textFieldStyle(.roundedBorder)
                                .font(.body.monospaced())
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.none)
                                
                            if showValidationError {
                                Text("验证文本不匹配，请重新输入")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // 执行删除按钮
                        Button(action: {
                            validateAndDelete()
                        }) {
                            HStack {
                                Spacer()
                                Text("永久删除所有数据")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(confirmationText != deleteConfirmationKeyword)
                        .opacity(confirmationText != deleteConfirmationKeyword ? 0.6 : 1.0)
                    }
                    .padding(.vertical, 8)
                }
                
                // 数据修复分组
                Section("数据修复") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("修复分数显示异常")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Text("检查并修复可能存在的分数/满分颠倒问题")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: {
                            fixScoreDisplayIssues()
                        }) {
                            HStack {
                                Spacer()
                                Text("执行数据修复")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding(.vertical, 8)
                }
                
                // 调试信息分组
                Section("调试信息") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("应用版本")
                                    .font(.headline)
                                Text("v6.0 (Debug Mode)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 数据计数信息
                        DataCountView()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("调试设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .alert("确认操作", isPresented: $showingDeleteConfirmation) {
                Button("取消", role: .cancel) { }
                Button("确认删除", role: .destructive) {
                    performDataDeletion()
                }
            } message: {
                Text("此操作将永久删除所有数据，确定要继续吗？")
            }
        }
    }
    
    /// 验证输入并准备删除
    private func validateAndDelete() {
        if confirmationText == deleteConfirmationKeyword {
            showValidationError = false
            showingDeleteConfirmation = true
        } else {
            showValidationError = true
            confirmationText = ""
        }
    }
    
    /// 执行数据删除操作
    private func performDataDeletion() {
        do {
            // 删除所有模型数据
            try modelContext.delete(model: Subject.self)
            try modelContext.delete(model: Exam.self)
            try modelContext.delete(model: ExamGroup.self)
            try modelContext.delete(model: Question.self)
            try modelContext.delete(model: PaperTemplate.self)
            try modelContext.delete(model: QuestionTemplate.self)
            try modelContext.delete(model: PaperStructure.self)
            try modelContext.delete(model: QuestionDefinition.self)
            try modelContext.delete(model: TestMethod.self)
            try modelContext.delete(model: QuestionType.self)
            
            print("[\(Date())] 所有数据已清除")
            
            // 重置验证状态
            confirmationText = ""
            showValidationError = false
            
            // 关闭调试视图
            dismiss()
            
        } catch {
            print("[\(Date())] 清除数据失败: \(error.localizedDescription)")
        }
    }
    
    /// 修复分数显示异常
    private func fixScoreDisplayIssues() {
        do {
            let exams = try modelContext.fetch(FetchDescriptor<Exam>())
            var fixedCount = 0
            
            for exam in exams {
                if let subject = exam.subject {
                    let subjectTotal = subject.totalScore
                    // 情况A：分数和满分明显颠倒（score>totalScore 且 score 接近科目满分）
                    let caseA = exam.score > exam.totalScore && abs(exam.score - subjectTotal) < 0.1
                    // 情况B：分数为0，但"满分"看起来像实际得分（>0 且 != 科目满分 且 <= 科目满分）
                    let caseB = exam.score == 0 && exam.totalScore > 0 && abs(exam.totalScore - subjectTotal) > 0.1 && exam.totalScore <= subjectTotal
                    
                    if caseA || caseB {
                        let originalScore = exam.score
                        let originalTotal = exam.totalScore
                        
                        exam.score = originalTotal
                        exam.totalScore = originalScore
                        exam.markAsUpdated()
                        
                        fixedCount += 1
                        print("[\(Date())] 修复考试：\(exam.name), 分数：\(originalScore) -> \(exam.score), 满分：\(originalTotal) -> \(exam.totalScore)")
                    }
                }
            }
            
            try modelContext.save()
            print("[\(Date())] 数据修复完成，共修复 \(fixedCount) 条记录")
            
        } catch {
            print("[\(Date())] 数据修复失败：\(error.localizedDescription)")
        }
    }
}

/// 显示数据计数的辅助视图
private struct DataCountView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var counts: [String: Int] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(counts.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack {
                    Text(key)
                        .font(.caption.monospaced())
                    Spacer()
                    Text("\(value)")
                        .font(.caption.monospaced())
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            updateCounts()
        }
    }
    
    private func updateCounts() {
        do {
            counts["科目"] = try modelContext.fetchCount(FetchDescriptor<Subject>())
            counts["考试"] = try modelContext.fetchCount(FetchDescriptor<Exam>())
            counts["考试组"] = try modelContext.fetchCount(FetchDescriptor<ExamGroup>())
            counts["题目"] = try modelContext.fetchCount(FetchDescriptor<Question>())
            counts["模板"] = try modelContext.fetchCount(FetchDescriptor<PaperTemplate>())
            counts["卷子结构"] = try modelContext.fetchCount(FetchDescriptor<PaperStructure>())
            counts["题型"] = try modelContext.fetchCount(FetchDescriptor<QuestionType>())
            counts["考法"] = try modelContext.fetchCount(FetchDescriptor<TestMethod>())
        } catch {
            print("[\(Date())] 获取数据计数失败: \(error.localizedDescription)")
        }
    }
}