//
//  // AddDataView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData
import Foundation

// [V16] 定义一个枚举，用于从外部传入要添加的数据类型。
enum AddableDataType {
    case exam
    case practice
}

struct AddDataView: View {
    // =======================================================================
    // MARK: - Properties & State
    // =======================================================================
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // [V16] 视图的输入：要添加的数据类型。
    let dataType: AddableDataType
    
    // [V16] 使用 @State 来管理UI的状态，这些是临时的“草稿”数据。
    @State private var name: String = ""
    @State private var date: Date = .now
    @State private var score: String = ""
    
    // [V16] 专门用于考试表单的状态
    @State private var selectedSubject: Subject?
    @State private var selectedExamCollection: ExamCollection?
    
    // [V16] 专门用于练习表单的状态
    @State private var selectedPracticeCollection: PracticeCollection?
    
    // [V16] 模拟从数据库中获取的数据，用于Picker选择。
    // [V9] 在真实应用中，这些将由 @Query 动态获取。
    private var availableSubjects: [Subject] = [] // 替换为 @Query
    private var availableExamCollections: [ExamCollection] = [] // 替换为 @Query
    private var availablePracticeCollections: [PracticeCollection] = [] // 替换为 @Query

    // =======================================================================
    // MARK: - Main Body
    // =======================================================================
    
    var body: some View {
        NavigationView {
            Form {
                // [V16] 视图主体非常简洁，只包含了几个封装好的组件。
                HeaderView(dataType: dataType)
                
                // [V16] 根据传入的类型，条件性地显示不同的表单。
                switch dataType {
                case .exam:
                    examForm
                case .practice:
                    practiceForm
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // [V16] 使用最新的 .topBarTrailing placement。
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存", action: saveData)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
    
    // =======================================================================
    // MARK: - Computed Properties
    // =======================================================================
    
    private var navigationTitle: String {
        switch dataType {
        case .exam:
            return "添加考试"
        case .practice:
            return "添加练习"
        }
    }
    
    // =======================================================================
    // MARK: - Encapsulated View Components
    // =======================================================================
    
    /// [V16] 封装的头部视图，包含图标和大标题。
    private var HeaderView: some View {
        VStack(spacing: 8) {
            Image(systemName: dataType == .exam ? "doc.text.fill" : "pencil.and.ruler.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .padding()
                .background(Circle().fill(Color.accentColor.gradient))
            
            Text(navigationTitle)
                .font(.title2).bold()
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear) // 让背景透明以融入Form
    }
    
    /// [V16] 封装的考试专用表单。
    private var examForm: some View {
        Section(header: Text("核心信息")) {
            TextField("考试名称，如：期中数学", text: $name)
            DatePicker("日期", selection: $date, displayedComponents: .date)
            TextField("成绩", text: $score)
                .keyboardType(.decimalPad)
            
            // [V16] 此处应为自定义的Menu Picker，用于选择科目和考试组
            // Picker("科目", selection: $selectedSubject) { ... }
            // Picker("考试组 (可选)", selection: $selectedExamCollection) { ... }
        }
        
        // [V16] 排名信息等其他Section可以继续在此处封装和添加。
        // Section(header: Text("班级表现")) { ... }
    }
    
    /// [V16] 封装的练习专用表单。
    private var practiceForm: some View {
        Section(header: Text("核心信息")) {
            // [V16] 此处应为自定义的Menu Picker，用于选择练习组
            // Picker("所属类别", selection: $selectedPracticeCollection) { ... }
            
            DatePicker("日期", selection: $date, displayedComponents: .date)
            TextField("成绩", text: $score)
                .keyboardType(.decimalPad)
        }
    }
    
    // =======================================================================
    // MARK: - Functions
    // =======================================================================
    
    private func saveData() {
        // [V16] 此处将实现将 @State 中的“草稿”数据
        // [V16] 转换为我们设计的SwiftData模型，并使用 modelContext.insert() 保存。
        // [V16] 逻辑会根据 dataType 的不同而有所区别。
        
        print("保存按钮被点击，准备保存数据...")
        
        // [V16] 保存成功后关闭视图。
        dismiss()
    }
}


// =======================================================================
// MARK: - Preview
// =======================================================================

#Preview("添加考试") {
    // [V16] 在预览中传入 .exam 类型
    AddDataView(dataType: .exam)
}

#Preview("添加练习") {
    // [V16] 在预览中传入 .practice 类型
    AddDataView(dataType: .practice)
}
