//
//  ExamDetailView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 考试详细信息视图，以列表形式展示单次考试的详细信息。
// 不包含图表和查询，专注于展示考试的基本信息和操作选项。

import SwiftUI
import SwiftData
import Foundation

struct ExamDetailView: View {
    let exam: Exam
    
    @State private var showingEditView = false
    
    // 简化的初始化方法，不再包含查询
    init(exam: Exam) {
        self.exam = exam
    }
    
    // MARK: - 计算属性
    
    /// 安全地获取科目名称
    private var safeSubjectName: String {
        exam.subject?.name ?? "未分类"
    }
    
    /// 计算得分率
    private var scorePercentage: Double {
        guard exam.totalScore > 0 else { return 0 }
        return (exam.score / exam.totalScore) * 100
    }
    
    /// 格式化日期
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: exam.date)
    }
    
    /// 格式化时间
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: exam.date)
    }
    
    // 定义视图的主要内容
    var body: some View {
        List {
            // 样式标题
            Section("样本详细信息") {
                HStack {
                    Text("科目")
                    Spacer()
                    Text(safeSubjectName)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("考试名称")
                    Spacer()
                    Text(exam.name)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("日期")
                    Spacer()
                    Text(formattedDate)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("时间")
                    Spacer()
                    Text(formattedTime)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("分数")
                    Spacer()
                    Text("\(Int(exam.score)) / \(Int(exam.totalScore))")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("得分率")
                    Spacer()
                    Text(String(format: "%.1f%%", scorePercentage))
                        .foregroundColor(.secondary)
                }
            }
            
            if let classRank = exam.classRank {
                Section("班级排名") {
                    HStack {
                        Text("名次")
                        Spacer()
                        Text("第\(classRank.rank)名")
                            .foregroundColor(.secondary)
                    }
                    if let avg = classRank.averageScore {
                        HStack {
                            Text("平均分")
                            Spacer()
                            Text(String(format: "%.1f", avg))
                                .foregroundColor(.secondary)
                        }
                    }
                    if let median = classRank.medianScore {
                        HStack {
                            Text("中位分")
                            Spacer()
                            Text(String(format: "%.1f", median))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if let gradeRank = exam.gradeRank {
                Section("年级排名") {
                    HStack {
                        Text("名次")
                        Spacer()
                        Text("第\(gradeRank.rank)名")
                            .foregroundColor(.secondary)
                    }
                    if let avg = gradeRank.averageScore {
                        HStack {
                            Text("平均分")
                            Spacer()
                            Text(String(format: "%.1f", avg))
                                .foregroundColor(.secondary)
                        }
                    }
                    if let median = gradeRank.medianScore {
                        HStack {
                            Text("中位分")
                            Spacer()
                            Text(String(format: "%.1f", median))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // 操作
            Section {
                Button {
                    showingEditView = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.orange)
                        Text("编辑考试")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("详细信息")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditView) {
            NavigationView {
                AddDataView(dataType: Binding.constant(.exam), examToEdit: exam, preselectedSubject: nil)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subject.self, Exam.self, configurations: config)
    let context = container.mainContext
    
    let subject = Subject(name: "数学", totalScore: 150, orderIndex: 0)
    context.insert(subject)
    
    let exam = Exam(name: "期中考试", date: Date(), score: 120, totalScore: 150, subject: subject)
    context.insert(exam)
    try? context.save()
    
    return NavigationStack { ExamDetailView(exam: exam) }
        .modelContainer(container)
}