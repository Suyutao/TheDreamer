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
    
    let subject: Subject?
    
    // [V25] 新增：一个闭包，用于将保存操作的结果传递回父视图。
    // [V25] 它接受两个参数：科目名称和总分。
    var onSave: (String, Double) -> Void
    
    @State private var name: String = ""
    @State private var totalScoreText: String = ""
    
    // MARK: - Computed Properties
    private var isSaveButtonDisabled: Bool {
        // [V24] 实时表单验证逻辑
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              let score = Double(totalScoreText) else {
            return true
        }
        // [V24] 验证分数是否在合理范围内
        return score < 1 || score > 1000
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
        guard let scoreValue = Double(totalScoreText) else { return }
        // [V25] 调用 onSave 闭包，将数据传出
        onSave(name.trimmingCharacters(in: .whitespaces), scoreValue)
        dismiss()
    }
}
