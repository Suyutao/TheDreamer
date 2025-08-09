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
    @State private var showingDebugSettings = false
    @State private var showingAbout = false
    @State private var showingOnBoarding = false
    
    // 引导完成状态
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationStack {
            List {
                    Section("数据管理") {
                        // 科目管理
                        ZStack {
                            Button(action: { showingManageSubjects = true }) {
                                EmptyView()
                            }
                            .opacity(0)
                            
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
                            .contentShape(Rectangle())
                        }
                        
                        // 考试组管理
                        ZStack {
                            Button(action: { showingManageExamGroups = true }) {
                                EmptyView()
                            }
                            .opacity(0)
                            
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
                            .contentShape(Rectangle())
                        }
                    
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
                
                // 调试功能分组
                Section("调试功能") {
                    // 调试设置入口
                    ZStack {
                        Button(action: { showingDebugSettings = true }) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        HStack {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("调试设置")
                                    .foregroundColor(.primary)
                                Text("清除数据、调试信息等")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .contentShape(Rectangle())
                    }
                }
                
                // 应用信息分组
                Section("关于") {
                    // 关于应用详情
                    ZStack {
                        Button(action: { showingAbout = true }) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("关于 The Dreamer")
                                    .foregroundColor(.primary)
                                Text("查看详细信息、许可证和贡献指南")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .contentShape(Rectangle())
                    }
                    
                    // 重新查看引导
                    ZStack {
                        Button(action: { showingOnBoarding = true }) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("重新查看引导")
                                    .foregroundColor(.primary)
                                Text("重新体验应用介绍和功能说明")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .contentShape(Rectangle())
                    }
                    
                    // 版本信息
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("版本信息")
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
        // 调试设置页面
        .sheet(isPresented: $showingDebugSettings) {
            DebugSettingsView()
                .environment(\.modelContext, modelContext)
        }
        // 关于页面
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        // OnBoarding页面
        .sheet(isPresented: $showingOnBoarding) {
            OnBoardingView(isReviewMode: true)
        }
    }
    

}

// 预览代码
#Preview {
    SettingsView()
}