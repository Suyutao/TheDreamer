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
    
    // 状态变量控制sheet的显示
    @State private var showingEditSheet = false
    @State private var showingAddDataSheet = false
    @State private var addableDataType: AddableDataType? = nil
    
    // 新增：本地状态 - 时间范围分段
    @State private var selectedRange: TimeRangeSelector.TimeRange = .month
    
    init(subject: Subject) {
        self.subjectID = subject.persistentModelID
    }
    
    // MARK: - Helper
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
    
    // 根据分段选择计算图表的数据点
    private func chartDataPoints(for subject: Subject) -> [ChartDataPoint] {
        let range = selectedRange.dateRange
        return subject.getScoreDataPoints(in: range)
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if let subject = modelContext.model(for: subjectID) as? Subject {
                ScrollView {
                    VStack(spacing: 12) {
                        // 顶部工具条 + 标题
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(Color(.systemGray6), in: Circle())
                            }
                            Spacer()
                            Text(subject.name)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                addableDataType = .exam
                                showingAddDataSheet = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(Color(.systemGray6), in: Circle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // 分段控制器
                        HStack {
                            TimeRangeSelector(selectedRange: $selectedRange)
                        }
                        .padding(.horizontal)
                        
                        // 白色图表容器
                        VStack(alignment: .leading, spacing: 12) {
                            // 图表：当前仅放置真实折线图，若无数据则显示空态
                            let points = chartDataPoints(for: subject)
                            if points.isEmpty {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                    Text("暂无数据")
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 220)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            } else {
                                VStack(spacing: 0) {
                                    LineChartView(
                                        dataPoints: points,
                                        selectedSubject: subject.name,
                                        dateRange: selectedRange.dateRange,
                                        visibleLines: [.myScore],
                                        chartStyle: .smooth,
                                        showYAxisAsPercentage: false
                                    )
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        // 灰色分组卡片：描述
                        VStack(alignment: .leading, spacing: 8) {
                            Text("[\(subject.name)]")
                                .font(.headline).bold()
                            Text(subject.subjectDescription.isEmpty ? "[占位文本]Lorem ipsum dolor sit amet, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam" : subject.subjectDescription)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        // 选项卡片
                        VStack(alignment: .leading, spacing: 8) {
                            Text("选项")
                                .font(.headline)
                            Button {
                                subject.pinned.toggle()
                                subject.markAsUpdated()
                                try? modelContext.save()
                            } label: {
                                HStack {
                                    Text("在摘要中置顶")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if subject.pinned {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        // 底部列表：显示所有数据 / 编辑科目
                        VStack(spacing: 8) {
                            NavigationLink(destination: SubjectDataView(subject: subject)) {
                                HStack {
                                    Text("显示所有数据")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Button(action: { showingEditSheet = true }) {
                                HStack {
                                    Text("编辑科目")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
                .navigationBarHidden(true)
                // 编辑科目的sheet
                .sheet(isPresented: $showingEditSheet) {
                    SubjectEditView(subject: subject) { name, totalScore, editedSubject in
                        if let editedSubject = editedSubject {
                            editedSubject.name = name
                            editedSubject.totalScore = totalScore
                            editedSubject.markAsUpdated()
                            try? modelContext.save()
                        }
                    }
                }
                // 添加数据的sheet
                .sheet(isPresented: $showingAddDataSheet) {
                    AddDataView(
                        dataType: $addableDataType,
                        examToEdit: nil,
                        preselectedSubject: subject
                    )
                }
            } else {
                EmptyStateView(
                    iconName: "exclamationmark.triangle.fill",
                    title: "科目不存在",
                    message: "该科目已被删除或不存在。"
                )
                .navigationTitle("科目详情")
                .onAppear { dismiss() }
            }
        }
    }
}
