//
//  The_DreamerApp.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/23/25.
//

import SwiftUI
import SwiftData

@main
struct TheDreamerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [UserProfile.self, ExamGroup.self, SubjectScore.self])
    }
}
