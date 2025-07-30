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
        Text("科目详情: \(subject.name)")
            .navigationTitle(subject.name)
    }
}
