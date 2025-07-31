//
//  MainTabView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI

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
