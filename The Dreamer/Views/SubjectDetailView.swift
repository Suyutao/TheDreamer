//
//  SubjectDetailView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

/// [V22] 科目详情视图。我们将在未来实现其完整功能。
struct SubjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let subjectID: PersistentIdentifier
    
    init(subject: Subject) {
        self.subjectID = subject.persistentModelID
    }
    
    var body: some View {
        Group {
            if let subject = modelContext.model(for: subjectID) as? Subject {
                EmptyStateView(
                    iconName: "book.fill",
                    title: "科目详情开发中",
                    message: "\(subject.name) 的详细功能正在开发中，敬请期待更多精彩内容。"
                )
                .navigationTitle(subject.name)
            } else {
                EmptyStateView(
                    iconName: "exclamationmark.triangle.fill",
                    title: "科目不存在",
                    message: "该科目已被删除或不存在。"
                )
                .navigationTitle("科目详情")
                .onAppear {
                    // 如果科目不存在，自动返回上一级
                    dismiss()
                }
            }
        }
    }
}
