//
//  SubjectEditView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件定义了一个用于添加或编辑科目的用户界面。
// 用户可以输入科目名称和满分值，并保存到数据库中。
//
// 常用名词说明：
// View: SwiftUI 中的视图，用于构建用户界面。
// struct: Swift 中的结构体，用于定义自定义数据类型。
// @State: SwiftUI 中的属性包装器，用于管理视图的内部状态。
// @Environment: SwiftUI 中的属性包装器，用于访问环境中的值。
// @Query: SwiftData 中的属性包装器，用于查询数据。
// NavigationView: SwiftUI 中的导航视图容器。
// Form: SwiftUI 中的表单视图。
// TextField: SwiftUI 中的文本输入框。
// Button: SwiftUI 中的按钮。
//

import SwiftUI
import SwiftData

/// 用于添加或编辑科目的视图
struct SubjectEditView: View {
    // MARK: - Properties & State
    
    /// 用于关闭当前视图的环境变量
    @Environment(\.dismiss) private var dismiss
    
    /// 用于访问 SwiftData 模型上下文的环境变量
    @Environment(\.modelContext) private var modelContext
    
    /// 查询所有科目的数组
    @Query private var subjects: [Subject]
    
    /// 要编辑的科目对象，如果为 nil 则表示添加新科目
    let subject: Subject?
    
    // [V25] 新增：一个闭包，用于将保存操作的结果传递回父视图。
    // [V25] 它接受两个参数：科目名称和总分。
    /// 保存操作的回调闭包，用于将保存的科目信息传递回父视图
    /// - Parameters:
    ///   - String: 科目名称
    ///   - Double: 科目总分
    ///   - Subject?: 被编辑的科目对象
    var onSave: (String, Double, Subject?) -> Void
    
    /// 科目名称的绑定状态变量
    @State private var name: String = ""
    
    /// 科目总分的绑定状态变量（文本形式）
    @State private var totalScoreText: String = ""
    
    // MARK: - Computed Properties
    
    /// 计算保存按钮是否禁用
    /// 检查科目名称是否为空、总分是否有效、是否与现有科目同名
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
    
    /// 计算导航标题字符串
    /// 如果 subject 为 nil 则显示"添加新科目"，否则显示"编辑科目"
    private var navigationTitleString: String {
        subject == nil ? "添加新科目" : "编辑科目"
    }

    // MARK: - Main Body
    
    /// 视图的主体部分
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
    
    /// 设置初始状态
    /// 如果正在编辑科目，则将科目名称和总分填充到输入框中
    private func setupInitialState() {
        if let subject = subject {
            name = subject.name
            totalScoreText = "\(subject.totalScore)"
        }
    }
    
    /// 保存科目信息
    /// 验证输入数据并调用 onSave 回调将数据传递给父视图
    private func save() {
        // [V26] 使用 Int 进行转换
        guard let scoreValue = Int(totalScoreText) else { return }
        
        // [V26] 将 Int 转换为 Double 传递出去，因为我们的模型需要 Double
        onSave(name.trimmingCharacters(in: .whitespaces), Double(scoreValue), subject)
        dismiss()
    }
}
