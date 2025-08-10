//
//  SubjectDetailView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

/// [V22] 科目详情视图。显示科目的基本信息和操作选项。
struct SubjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let subjectID: PersistentIdentifier
    
    init(subject: Subject) {
        self.subjectID = subject.persistentModelID
    }
    
    /// 获取指定科目的SF Symbol图标
    private func getSubjectIcon(for subject: Subject) -> String {
        switch subject.name {
        case let name where name.contains("语文"):
            return "text.book.closed"
        case let name where name.contains("数学"):
            return "function"
        case let name where name.contains("英语"):
            return "textformat.abc"
        case let name where name.contains("物理"):
            return "atom"
        case let name where name.contains("化学"):
            return "flask"
        case let name where name.contains("生物"):
            return "leaf"
        case let name where name.contains("历史"):
            return "clock"
        case let name where name.contains("地理"):
            return "globe.asia.australia"
        case let name where name.contains("政治"):
            return "building.columns"
        default:
            return "book"
        }
    }
    
    /// 获取指定科目的最新考试记录
    private func getLatestExam(for subject: Subject) -> Exam? {
        subject.exams.sorted { $0.date > $1.date }.first
    }
    
    var body: some View {
        Group {
            if let subject = modelContext.model(for: subjectID) as? Subject {
                List {
                    Section {
                        // 科目成绩图表卡片
                        if let latestExam = getLatestExam(for: subject) {
                            SubjectScoreLineChart(
                                subjectName: subject.name,
                                score: latestExam.score,
                                date: latestExam.date,
                                iconSystemName: getSubjectIcon(for: subject)
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        } else {
                            // 如果没有考试数据，显示空状态卡片
                            VStack(spacing: 12) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("暂无成绩数据")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("添加考试记录后，这里将显示成绩趋势图")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                    
                    Section {
                        NavigationLink(destination: SubjectDataView(subject: subject)) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("所有数据")
                                        .font(.headline)
                                    Text("查看该科目的所有考试记录")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        NavigationLink(destination: SubjectEditView(
                            subject: subject,
                            onSave: { name, totalScore, editedSubject in
                                if let editedSubject = editedSubject {
                                    editedSubject.name = name
                                    editedSubject.totalScore = totalScore
                                    try? modelContext.save()
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.orange)
                                    .frame(width: 24, height: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("编辑科目")
                                        .font(.headline)
                                    Text("修改科目名称和满分")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle(subject.name)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(destination: AddDataView(dataType: .constant(.exam), examToEdit: nil, preselectedSubject: subject)) {
                            Image(systemName: "plus")
                        }
                    }
                }
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
