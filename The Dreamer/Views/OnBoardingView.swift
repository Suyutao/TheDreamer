//
//  OnBoardingView.swift
//  The Dreamer
//
//  Created by AI Assistant on 8/6/25.
//

// 功能简介：
// OnBoardingView 是应用的首次使用引导视图，它包含3-4个引导页面：
// 1. 欢迎页面 - 介绍应用的核心理念
// 2. 功能介绍页面 - 展示核心功能：添加考试、查看分析、管理科目
// 3. 权限说明页面 - 解释通知权限等必要权限
// 4. 开始使用页面 - 引导用户添加第一个科目或示例数据

// 常用名词说明：
// TabView: SwiftUI 中的标签页视图容器，这里用作页面滑动容器
// @AppStorage: SwiftUI 中的属性包装器，用于在 UserDefaults 中存储简单数据
// @State: SwiftUI 中的状态属性包装器，用于管理视图内部状态
// PageTabViewStyle: TabView 的页面样式，支持左右滑动切换

import SwiftUI
import SwiftData

/// OnBoardingView 是应用的首次使用引导视图
struct OnBoardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 使用 @AppStorage 检测是否为首次启动
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // 是否为重新查看模式（从设置页面进入）
    let isReviewMode: Bool
    
    // 初始化方法
    init(isReviewMode: Bool = false) {
        self.isReviewMode = isReviewMode
    }
    
    // 当前页面索引
    @State private var currentPage = 0
    
    // 引导页面总数
    private let totalPages = 4
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar
                
                // 主要内容区域
                TabView(selection: $currentPage) {
                    // 第1页：欢迎页面
                    welcomePage
                        .tag(0)
                    
                    // 第2页：功能介绍
                    featuresPage
                        .tag(1)
                    
                    // 第3页：权限说明
                    permissionsPage
                        .tag(2)
                    
                    // 第4页：开始使用
                    getStartedPage
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // 底部控制区域
                bottomControlArea
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar: some View {
        HStack {
            // 页面指示器
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            
            Spacer()
            
            // 跳过按钮
            if currentPage < totalPages - 1 {
                Button("跳过") {
                    completeOnboarding()
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - 引导页面内容
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 应用图标
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            VStack(spacing: 16) {
                Text("欢迎使用 The Dreamer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("由学生打造，为学生服务\n通过数据分析实现学习的自由、秩序与自我掌控")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var featuresPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("核心功能")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 30) {
                FeatureRow(
                    icon: "plus.circle.fill",
                    title: "添加考试数据",
                    description: "快速录入考试成绩，支持多科目管理",
                    color: .green
                )
                
                FeatureRow(
                    icon: "chart.bar.xaxis",
                    title: "数据分析",
                    description: "可视化图表展示学习趋势和进步轨迹",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "rectangle.3.group",
                    title: "智能仪表板",
                    description: "一目了然的学习数据概览和洞察",
                    color: .orange
                )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var permissionsPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(.green.gradient)
            
            VStack(spacing: 16) {
                Text("隐私与权限")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("The Dreamer 重视您的隐私")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 20) {
                PermissionRow(
                    icon: "bell.fill",
                    title: "通知权限",
                    description: "用于提醒您定期记录学习数据（可选）"
                )
                
                PermissionRow(
                    icon: "internaldrive.fill",
                    title: "本地存储",
                    description: "所有数据仅存储在您的设备上，完全私密"
                )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var getStartedPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "rocket.fill")
                .font(.system(size: 60))
                .foregroundStyle(.purple.gradient)
            
            VStack(spacing: 16) {
                Text("开始您的学习之旅")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("选择一种方式开始使用 The Dreamer")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                if isReviewMode {
                    // 重新查看模式只显示完成按钮
                    Button(action: {
                        completeOnboarding()
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("完成查看")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    // 首次启动模式显示两个选项
                    Button(action: {
                        completeOnboardingWithSampleData()
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("添加示例数据")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        completeOnboarding()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("手动添加科目")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 底部控制区域
    
    private var bottomControlArea: some View {
        HStack {
            // 上一页按钮
            if currentPage > 0 {
                Button("上一页") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage -= 1
                    }
                }
                .foregroundColor(.secondary)
            } else {
                // 占位符保持布局平衡
                Text("")
            }
            
            Spacer()
            
            // 下一页/完成按钮
            if currentPage < totalPages - 1 {
                Button("下一页") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                }
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - 辅助方法
    
    /// 完成引导流程
    private func completeOnboarding() {
        // 只有在首次启动时才设置完成状态
        if !isReviewMode {
            hasCompletedOnboarding = true
        }
        dismiss()
    }
    
    /// 完成引导流程并添加示例数据
    private func completeOnboardingWithSampleData() {
        // 只有在首次启动时才创建示例数据
        if !isReviewMode {
            createSampleData()
        }
        completeOnboarding()
    }
    
    /// 创建示例数据
    private func createSampleData() {
        // 检查是否已存在科目，避免重复创建
        let descriptor = FetchDescriptor<Subject>()
        let existingSubjects = (try? modelContext.fetch(descriptor)) ?? []
        
        // 如果已有科目，不创建示例数据
        if !existingSubjects.isEmpty {
            print("[\(Date())] 已存在科目，跳过示例数据创建")
            return
        }
        
        // 创建示例科目
        let mathSubject = Subject(name: "数学", totalScore: 150, orderIndex: 0)
        let englishSubject = Subject(name: "英语", totalScore: 150, orderIndex: 1)
        let physicsSubject = Subject(name: "物理", totalScore: 100, orderIndex: 2)
        
        modelContext.insert(mathSubject)
        modelContext.insert(englishSubject)
        modelContext.insert(physicsSubject)
        
        // 创建示例考试数据
        let exam1 = Exam(
            name: "期中考试",
            date: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            totalScore: 400,
            subject: mathSubject
        )
        
        let exam2 = Exam(
            name: "月考",
            date: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            totalScore: 400,
            subject: mathSubject
        )
        
        modelContext.insert(exam1)
        modelContext.insert(exam2)
        
        // 保存数据
        do {
            try modelContext.save()
            print("[\(Date())] 示例数据创建成功")
        } catch {
            print("[\(Date())] 创建示例数据失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - 辅助视图组件

/// 功能介绍行组件
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color.gradient)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

/// 权限说明行组件
struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    OnBoardingView()
}