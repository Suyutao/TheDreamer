//
//  DashboardView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI

struct DashboardView: View {
    
    // 计算当前是第几周
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
