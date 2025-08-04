//
//  SettingsView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件定义了应用的设置页面，提供统一的管理入口。
// 包括科目管理、考试组管理和未来的模板管理功能。

import SwiftUI
import SwiftData

// 定义设置页面视图
struct SettingsView: View {
    // 获取应用程序的数据存储上下文
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 状态变量控制各个管理页面的显示
    @State private var showingManageSubjects = false
    @State private var showingManageExamGroups = false
    @State private var showingClearDataAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // 数据管理分组
                Section("数据管理") {
                    // 科目管理
                    Button(action: { showingManageSubjects = true }) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("科目管理")
                                    .foregroundColor(.primary)
                                Text("添加、编辑或删除科目")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 考试组管理
                    Button(action: { showingManageExamGroups = true }) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("考试组管理")
                                    .foregroundColor(.primary)
                                Text("管理联考和考试组")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 模板管理（未来功能）
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("模板管理")
                                .foregroundColor(.secondary)
                            Text("即将推出")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("敬请期待")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 危险操作分组
                Section("危险操作") {
                    // 清除所有数据
                    Button(action: {
                        showingClearDataAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("清除所有数据")
                                    .foregroundColor(.red)
                                Text("删除所有科目、考试、练习等数据")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 应用信息分组
                Section("关于") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("The Dreamer")
                                .foregroundColor(.primary)
                            Text("由学生打造，为学生服务")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("v6.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        // 科目管理页面
        .sheet(isPresented: $showingManageSubjects) {
            ManageSubjectsView()
                .environment(\.modelContext, modelContext)
        }
        // 考试组管理页面
        .sheet(isPresented: $showingManageExamGroups) {
            ExamGroupManagementView()
                .environment(\.modelContext, modelContext)
        }
        // 清除数据确认弹窗
        .alert("确认清除数据", isPresented: $showingClearDataAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("此操作将删除所有科目、考试、练习等数据，且无法恢复。确定要继续吗？")
        }
    }
    
    // MARK: - 数据清除功能
    
    /// 清除所有数据的函数
    private func clearAllData() {
        do {
            // 删除所有模型数据
            try modelContext.delete(model: Subject.self)
            try modelContext.delete(model: Exam.self)
            try modelContext.delete(model: ExamGroup.self)
            try modelContext.delete(model: ExamSchedule.self)
            try modelContext.delete(model: Question.self)
            try modelContext.delete(model: QuestionResult.self)
            try modelContext.delete(model: PracticeCollection.self)
            try modelContext.delete(model: Practice.self)
            try modelContext.delete(model: PaperTemplate.self)
            try modelContext.delete(model: QuestionTemplate.self)
            try modelContext.delete(model: PaperStructure.self)
            try modelContext.delete(model: QuestionDefinition.self)
            try modelContext.delete(model: TestMethod.self)
            try modelContext.delete(model: QuestionType.self)
            try modelContext.delete(model: RankData.self)
            
            // 保存更改
            try modelContext.save()
            
            print("[\(Date())] 所有数据已成功清除")
        } catch {
            print("[\(Date())] 清除数据时发生错误: \(error)")
        }
    }
}

// 预览代码
#Preview {
    SettingsView()
}