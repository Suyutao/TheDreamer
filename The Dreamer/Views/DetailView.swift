//
//  ContentView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/23/25.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Query var subjectScores: [SubjectScore]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(subjectScores) { score in
                    NavigationLink(destination: ScoreDetailView(score: score)) {
                        Text("\(score.subject): \(score.score)")
                    }
                }
                .onDelete(perform: deleteScores)
            }
            .navigationTitle("成绩列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Text("添加成绩")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddDataView(showSheet: $showAddSheet)
        }
    }

    private func addScore() {
        let newScore = SubjectScore(isUnited: false, subject: "math", score: 120, fullScore: 150, isCurved: false, isElective: false, scoreRatio: 0.8)
        modelContext.insert(newScore)
    }

    private func deleteScores(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(subjectScores[index])
        }
    }
}

// 你可以自定义详情页
struct ScoreDetailView: View {
    var score: SubjectScore
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("科目：\(score.subject)")
            Text("分数：\(score.score)")
            Text("满分：\(score.fullScore)")
            // 其他字段...
        }
        .padding()
        .navigationTitle("成绩详情")
    }
}

// 新建添加数据的Sheet视图占位
struct AddDataView: View {
    @Binding var showSheet: Bool
    var body: some View {
        VStack {
            Text("这里是添加成绩的表单")
            Button("关闭") {
                showSheet = false
            }
        }
        .padding()
    }
}

#Preview {
    DetailView()
        .modelContainer(for: Item.self, inMemory: true)
}
