//
//  AnalysisView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

struct AnalysisView: View {
    @Environment(\.modelContext) private var modelContext
        
    // [V39] 使用@Query获取所有Exam记录，并按日期倒序排序
    @Query(sort: \Exam.date, order: .reverse) private var exams: [Exam]
    
    // [V1] 添加状态变量来存储要添加的数据类型
    @State private var addableDataType: AddableDataType = .exam
    
    @State private var showingAddDataSheet = false
    @State private var showingManageSheet = false // 新增：控制管理科目与模板sheet的显示
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // [V39] 如果没有数据，显示空状态
                if exams.isEmpty {
                    EmptyStateView(
                        iconName: "tray.fill",
                        title: "暂无成绩记录",
                        message: "点击右上角的“添加数据”按钮，开始记录你的第一次成绩吧！"
                    )
                } else {
                    // [V39] 列表显示所有成绩
                    List {
                        ForEach(exams) { exam in
                            ExamRowView(exam: exam)
                        }
                        .onDelete(perform: deleteExam)
                    }
                }
            }
            .navigationTitle("所有数据")
            .toolbar {
                // 左上角的视图管理菜单
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        // 这里将放置我们V20讨论过的视图切换选项
                        Button("按科目分组", action: {})
                        Button("按时间排序", action: {})
                        
                        Divider()
                        
                        Button("管理科目与模板...", action: { showingManageSheet = true }) // 修改：设置action为显示sheet
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                // 右上角的添加数据菜单
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("添加考试", action: {
                            addableDataType = .exam
                            showingAddDataSheet = true
                        })
                        
                        Button("添加练习", action: {
                            addableDataType = .practice
                            showingAddDataSheet = true
                        })
                    } label: {
                        Text("添加数据")
                    }
                }
            }
            .sheet(isPresented: $showingAddDataSheet) {
                // [V39] 关键：为弹出的Sheet注入modelContext环境
                AddDataView(dataType: addableDataType)
                    .environment(\.modelContext, modelContext)
            }
            .sheet(isPresented: $showingManageSheet) { // 新增：管理科目与模板的sheet
                ManageSubjectsView()
                    .environment(\.modelContext, modelContext)
            }
        }
    }
    private func deleteExam(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exams[index])
        }
    }
}

// [V39] 创建一个简单的行视图来显示成绩
struct ExamRowView: View {
    let exam: Exam
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exam.name)
                    .font(.headline)
                Text(exam.subject?.name ?? "未知科目")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(exam.totalScore, specifier: "%.1f")")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(exam.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AnalysisView()
}
