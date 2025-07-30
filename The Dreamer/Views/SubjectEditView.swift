//
//  SubjectEditView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI
import SwiftData

struct SubjectEditView: View {
    // MARK: - Properties & State
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var subjects: [Subject]
    
    let subject: Subject?
    
    // [V25] 新增：一个闭包，用于将保存操作的结果传递回父视图。
    // [V25] 它接受两个参数：科目名称和总分。
    var onSave: (String, Double, Subject?) -> Void
    
    @State private var name: String = ""
    @State private var totalScoreText: String = ""
    
    // MARK: - Computed Properties
    private var isSaveButtonDisabled: Bool {
        // 检查名称是否为空
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return true }
        
        // 检查是否能转换为 Int
        guard let score = Int(totalScoreText),
              // 确保没有小数点 (通过比较Int和Double的转换结果)
              Double(totalScoreText) == Double(score) else {
            return true
        }
        
        // 确保分数大于0
        guard score >= 1 else { return true }
        
        // 检查是否与现有科目同名
        let existingSubject = subjects.first { $0.name == name && $0 != subject }
        if existingSubject != nil {
            return true
        }
        
        return false
    }
    
    private var navigationTitleString: String {
        subject == nil ? "添加新科目" : "编辑科目"
    }

    // MARK: - Main Body
    var body: some View {
        NavigationView {
            Form {
                FormHeader(
                    iconName: "book.fill",
                    title: navigationTitleString,
                    iconColor: .orange
                )
                
                Section(header: Text("科目信息")) {
                    TextField("科目名称", text: $name)
                    TextField("满分 (1-1000)", text: $totalScoreText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        // [V24] 绑定按钮的禁用状态
                        .disabled(isSaveButtonDisabled)
                }
            }
            .onAppear(perform: setupInitialState)
        }
    }
    
    // MARK: - Functions
    private func setupInitialState() {
        if let subject = subject {
            name = subject.name
            totalScoreText = "\(subject.totalScore)"
        }
    }
    
    private func save() {
        // [V26] 使用 Int 进行转换
        guard let scoreValue = Int(totalScoreText) else { return }
        
        // [V26] 将 Int 转换为 Double 传递出去，因为我们的模型需要 Double
        onSave(name.trimmingCharacters(in: .whitespaces), Double(scoreValue), subject)
        dismiss()
    }
}
