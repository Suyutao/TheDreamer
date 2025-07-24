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

#Preview {
    DetailView()
        .modelContainer(for: Item.self, inMemory: true)
}
