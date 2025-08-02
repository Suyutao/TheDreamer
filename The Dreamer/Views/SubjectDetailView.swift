//
//  SubjectDetailView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI

/// [V22] 科目详情视图。我们将在未来实现其完整功能。
struct SubjectDetailView: View {
    let subject: Subject
    
    var body: some View {
        EmptyStateView(
            iconName: "book.fill",
            title: "科目详情开发中",
            message: "\(subject.name) 的详细功能正在开发中，敬请期待更多精彩内容。"
        )
        .navigationTitle(subject.name)
    }
}
