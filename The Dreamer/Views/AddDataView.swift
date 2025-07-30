// AddDataView.swift (V18 Final Corrected Version)

import SwiftUI
import SwiftData

enum AddableDataType {
    case exam
    case practice
}

struct AddDataView: View {
    
    // MARK: - Properties & State
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let dataType: AddableDataType
    
    // UI State
    @State private var examName: String = ""
    @State private var date: Date = .now
    @State private var scoreText: String = ""
    
    // Data Source State
    @State private var selectedSubject: Subject?
    @State private var selectedPracticeCollection: PracticeCollection?
    
    // Queries
    @Query(sort: \Subject.name) private var subjects: [Subject]
    @Query(sort: \PracticeCollection.name) private var practiceCollections: [PracticeCollection]

    // MARK: - Main Body
    var body: some View {
        NavigationView {
            Form {
                // [V23] 使用新的可复用组件
                FormHeader(
                    iconName: dataType == .exam ? "doc.text.fill" : "pencil.and.ruler.fill",
                    title: navigationTitle,
                    iconColor: .accentColor
                )
                
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存", action: saveData)
                        .disabled(isSaveButtonDisabled)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
  
    // MARK: - Encapsulated View Components
    
    private var examForm: some View {
        Section(header: Text("考试信息")) {
            TextField("考试名称，如：期中数学", text: $examName)
            DatePicker("日期", selection: $date, displayedComponents: .date)
            
            Picker("科目", selection: $selectedSubject) {
                Text("请选择科目").tag(nil as Subject?)
                ForEach(subjects) { subject in
                    Text(subject.name).tag(subject as Subject?)
                }
            }
            
            TextField("成绩", text: $scoreText)
                .keyboardType(.decimalPad)
        }
    }
    
    private var practiceForm: some View {
        Section(header: Text("练习信息")) {
            Picker("所属类别", selection: $selectedPracticeCollection) {
                Text("请选择类别").tag(nil as PracticeCollection?)
                ForEach(practiceCollections) { collection in
                    Text(collection.name).tag(collection as PracticeCollection?)
                }
            }
            
            DatePicker("日期", selection: $date, displayedComponents: .date)
            TextField("成绩", text: $scoreText)
                .keyboardType(.decimalPad)
        }
    }
    
    // MARK: - Computed Properties & Functions
    
    private var navigationTitle: String {
        dataType == .exam ? "添加考试" : "添加练习"
    }
    
    private var isSaveButtonDisabled: Bool {
        // [V18] 添加简单的表单验证，确保核心信息已填写
        if scoreText.isEmpty { return true }
        switch dataType {
        case .exam:
            return examName.isEmpty || selectedSubject == nil
        case .practice:
            return selectedPracticeCollection == nil
        }
    }
    
    private func saveData() {
        guard let scoreValue = Double(scoreText) else {
            print("错误：分数格式不正确")
            return // 真实应用中应有弹窗提示
        }
        
        switch dataType {
        case .exam:
            guard let subject = selectedSubject else { return }
            let newExam = Exam(name: examName, date: date, totalScore: scoreValue, subject: subject)
            modelContext.insert(newExam)
            
        case .practice:
            guard let collection = selectedPracticeCollection else { return }
            let newPractice = Practice(date: date, score: scoreValue, collection: collection)
            modelContext.insert(newPractice)
        }
        
        dismiss()
    }
}

// MARK: - Preview

#Preview("添加考试") {
    // [V18] 必须提供所有相关的模型给容器，以便预览正常工作
    AddDataView(dataType: .exam)
        .modelContainer(for: [Subject.self, Exam.self])
}

#Preview("添加练习") {
    AddDataView(dataType: .practice)
        .modelContainer(for: [PracticeCollection.self, Practice.self, Subject.self])
}
