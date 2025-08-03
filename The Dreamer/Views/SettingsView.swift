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
    }
}

// 预览代码
#Preview {
    SettingsView()
}