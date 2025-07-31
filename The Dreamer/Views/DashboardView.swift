//
//  DashboardView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// DashboardView 是应用的主页，用于展示用户的学习数据可视化图表。
// 它显示当前是学期的第几周，并提供一个空状态视图作为占位符，
// 未来将在这里展示成绩趋势的可视化图表。

// 常用名词说明：
// View: SwiftUI 中的视图协议，用于定义用户界面。
// struct: Swift 中的结构体，用于定义自定义数据类型。
// body: View 协议中的计算属性，用于定义视图的层次结构。
// NavigationView: SwiftUI 中的导航视图容器，用于管理导航层次结构。
// ScrollView: SwiftUI 中的滚动视图容器，用于容纳可滚动的内容。
// EmptyStateView: 自定义的空状态视图，用于在没有数据时显示提示信息。
// Calendar: Foundation 框架中的类，用于处理日历相关的计算。
// Date: Foundation 框架中的类，用于表示特定的时间点。

import SwiftUI

/// DashboardView 是应用的主页，用于展示用户的学习数据可视化图表。
struct DashboardView: View {
    
    /// 计算当前是学期的第几周
    /// - Returns: 当前是学期的第几周
    private var currentWeek: Int {
        // 这里可以放入你之前设定的学期开始日期逻辑
        // 为简单起见，我们先用一个占位符
        return Calendar.current.component(.weekOfYear, from: Date())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                // 使用我们的通用空状态视图作为占位符
                EmptyStateView(
                    iconName: "chart.pie.fill",
                    title: "图表正在赶来",
                    message: "在这里，你将看到关于成绩趋势的可视化图表。敬请期待！"
                )
                .padding(.top, 50)
            }
            .navigationTitle("第 \(currentWeek) 周")
        }
    }
}

#Preview {
    DashboardView()
}
