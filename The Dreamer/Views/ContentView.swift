//
//  ContentView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/23/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var subjectScores: [SubjectScore] // 查询所有成绩
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List(subjectScores) { score in
            Text("\(score.subject): \(score.score)")
        }
        Button("添加成绩") {
            let newScore = SubjectScore(isUnited: false, subject: "math", score: 120, fullScore: 150, isCurved: false, isElective: false, scoreRatio: 0.8)
            modelContext.insert(newScore)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
