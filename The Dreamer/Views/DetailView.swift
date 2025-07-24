//
//  DetailView.swift
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
    @State private var selectedType: EntryType = .homework

    var body: some View {
        NavigationView {
            List {
                ForEach(subjectScores) { score in
                    NavigationLink(destination: DataDetailView(score: score)) {
                        Text("\(score.subject): \(score.score)")
                    }
                }
                .onDelete(perform: deleteScores)
            }
            .navigationTitle("成绩列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Menu("单科") {
                            Button("数学") { selectedType = .singleSubject("数学"); showAddSheet = true }
                            Button("语文") { selectedType = .singleSubject("语文"); showAddSheet = true }
                            Button("英语") { selectedType = .singleSubject("英语"); showAddSheet = true }
                            Button("物理") { selectedType = .singleSubject("物理"); showAddSheet = true }
                            Button("化学") { selectedType = .singleSubject("化学"); showAddSheet = true }
                            Button("生物") { selectedType = .singleSubject("生物"); showAddSheet = true }
                        }
                        Button("全科考试") { selectedType = .fullExam; showAddSheet = true }
                        Button("作业") { selectedType = .homework; showAddSheet = true }
                    } label: {
                        Text("添加成绩")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddDataView(showSheet: $showAddSheet, entryType: selectedType)
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

#Preview {
    DetailView()
        .modelContainer(for: Item.self, inMemory: true)
}
