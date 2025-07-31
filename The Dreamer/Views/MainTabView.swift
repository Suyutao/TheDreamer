//
//  MainTabView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// MainTabView 是应用的主标签页视图，它包含两个标签页：
// 1. 仪表板 (DashboardView)
// 2. 分析 (AnalysisView)
// 用户可以通过点击底部的标签页图标来切换不同的视图。

// 常用名词说明：
// View: SwiftUI 中的视图协议，用于定义用户界面。
// struct: Swift 中的结构体，用于定义自定义数据类型。
// body: View 协议中的计算属性，用于定义视图的层次结构。
// TabView: SwiftUI 中的标签页视图容器，用于管理多个标签页。
// DashboardView: 应用的主页，用于展示用户的学习数据可视化图表。
// AnalysisView: 用于展示和分析用户考试和练习数据的视图。
// Label: SwiftUI 中的视图，用于显示文本和图标。

import SwiftUI

/// MainTabView 是应用的主标签页视图，它包含两个标签页：仪表板和分析。
struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("仪表板", systemImage: "rectangle.3.group")
                }
            
            AnalysisView()
                .tabItem {
                    Label("分析", systemImage: "chart.bar.xaxis")
                }
        }
    }
}

#Preview {
    MainTabView()
}
