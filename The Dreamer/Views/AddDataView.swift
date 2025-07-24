//
//  AddDataView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/24/25.
//


import SwiftData
import SwiftUI

enum EntryType {
    case singleSubject(String)
    case fullExam
    case homework
    
    var title: String {
        switch self {
        case .singleSubject(let subject): return "添加\(subject)成绩"
        case .fullExam: return "添加大考成绩"
        case .homework: return "添加作业"
        }
    }
}

struct AddDataView: View {
    @Binding var showSheet: Bool
    var entryType: EntryType
    
    @State private var selectedDate = Date()
    @State private var score = ""
    @State private var classRank = ""
    @State private var gradeRank = ""
    @State private var selectedSubject = "数学"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 日期选择器
                DatePicker("日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                // 全科考试科目选择器
                if case .fullExam = entryType {
                    Picker("科目", selection: $selectedSubject) {
                        Text("数学").tag("数学")
                        Text("语文").tag("语文")
                        Text("英语").tag("英语")
                        Text("物理").tag("物理")
                        Text("化学").tag("化学")
                        Text("生物").tag("生物")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 成绩输入
                TextField("成绩", text: $score)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // 班级排名
                TextField("班级排名", text: $classRank)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // 年级排名
                TextField("年级排名", text: $gradeRank)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // 班级年级数据导航链接
                NavigationLink("添加班级年级数据") {
                    Text("班级年级数据统计")
                        .navigationTitle("班级年级数据")
                }
                
                Spacer()
                
                Button("关闭") { showSheet = false }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle(entryType.title)
        }
    }
}

#Preview {
    AddDataView(showSheet: .constant(true), entryType: .singleSubject("数学"))
}