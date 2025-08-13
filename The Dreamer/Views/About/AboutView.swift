//
//  AboutView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件定义了应用的关于页面，展示项目的详细信息、许可证、贡献指南等。
// 包含致谢、许可证、行为准则、贡献指南等完整的项目文档信息。

import SwiftUI

// 定义关于页面视图
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 应用信息头部
                    VStack(spacing: 12) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("The Dreamer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("由学生打造，为学生服务")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("v6.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    
                    // 项目信息
                    DocumentSection(
                        title: "项目信息",
                        icon: "info.circle.fill",
                        iconColor: .blue,
                        content: projectInfo
                    )
                    
                    // 致谢
                    DocumentSection(
                        title: "致谢",
                        icon: "heart.fill",
                        iconColor: .red,
                        content: acknowledgements
                    )
                    
                    // 许可证
                    DocumentSection(
                        title: "许可证",
                        icon: "doc.text.fill",
                        iconColor: .green,
                        content: licenseInfo
                    )
                    
                    // 贡献指南
                    DocumentSection(
                        title: "贡献指南",
                        icon: "person.3.fill",
                        iconColor: .orange,
                        content: contributingGuide
                    )
                    
                    // 行为准则
                    DocumentSection(
                        title: "行为准则",
                        icon: "shield.fill",
                        iconColor: .purple,
                        content: codeOfConduct
                    )
                    
                    // 版权声明
                    DocumentSection(
                        title: "版权声明",
                        icon: "c.circle.fill",
                        iconColor: .gray,
                        content: copyrightNotice
                    )
                }
                .padding()
            }
            .navigationTitle("关于")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // 项目信息内容
    private var projectInfo: String {
        """
        The Dreamer 是一个专为学生设计的学习管理应用。
        
        技术栈：
        • SwiftUI + SwiftData + Swift Charts
        • iOS 18.0+
        • Xcode 16+
        
        核心功能：
        • 考试成绩管理
        • 数据可视化分析
        • 科目和考试组管理
        • 智能学习洞察
        
        开发理念：
        通过数据驱动的方式帮助学生更好地了解自己的学习状况，
        提供个性化的学习建议和改进方向。
        """
    }
    
    // 致谢内容
    private var acknowledgements: String {
        """
        本项目使用了来自 Apple Inc. 示例代码的组件。
        原始代码 © 2024 Apple Inc.，在以下许可条款下使用：
        详情请参阅 LICENSE-APPLE.txt。
        
        AI 开发工具：
        
        本项目主要通过 AI 协助开发。特别感谢：
        • Trae AI：主要开发环境和 AI 编程助手
        • Manus：项目规划和架构的 AI 助手
        
        虽然维护者对代码库有基本了解，但对 AI 工具的依赖使得
        这个项目在有限的深度技术专业知识下成为可能。
        """
    }
    
    // 许可证信息
    private var licenseInfo: String {
        """
        Apache License 2.0
        
        Copyright © 2025 苏宇韬
        
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
        
            http://www.apache.org/licenses/LICENSE-2.0
        
        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
        
        本软件按"原样"提供，不提供任何明示或暗示的保证。
        详细条款请参阅完整的 Apache 2.0 许可证文本。
        """
    }
    
    // 贡献指南内容
    private var contributingGuide: String {
        """
        感谢您对为 The Dreamer 贡献的兴趣！
        
        我们的理念：
        "由学生，为学生" - 每一个贡献都应该服务于学生在学习过程中的真实需求和痛点。
        
        如何贡献：
        
        1. 报告问题
        • 使用清晰、描述性的标题
        • 提供重现问题的步骤
        • 包含您的 iOS 版本和设备信息
        
        2. 建议功能
        • 解释此功能解决的学生痛点
        • 描述它如何符合"数据驱动学习"的理念
        
        3. 代码贡献
        • 遵循 Swift 命名约定
        • 使用有意义的变量和函数名
        • 为复杂逻辑添加注释
        • 确保代码编译时没有警告
        
        开发设置：
        • 要求：Xcode 16+，iOS 18+ SDK
        • 技术栈：SwiftUI，SwiftData，Swift Charts
        • 架构：MV（Model-View）模式
        
        请记住：这个项目是关于通过数据驱动学习赋能学生。
        每一行代码都应该服务于这个使命。
        """
    }
    
    // 行为准则内容
    private var codeOfConduct: String {
        """
        我们的承诺：
        
        为了营造一个开放和友好的环境，我们承诺让参与 The Dreamer 项目
        成为每个人都没有骚扰的体验。
        
        我们的标准：
        
        积极行为示例：
        • 以学生为中心的思考
        • 教育专注的讨论
        • 尊重沟通
        • 建设性反馈
        • 学术诚信
        
        不可接受的行为：
        • 骚扰、恶意攻击或歧视性评论
        • 未经许可发布他人的私人信息
        • 与教育目的无关的商业推广
        • 垃圾信息或离题讨论
        
        我们的教育使命：
        
        The Dreamer 是"由学生打造，为学生服务"的。
        所有社区互动都应该：
        • 支持通过数据驱动学习赋能学生的目标
        • 维护项目免费开源的承诺
        • 尊重学生贡献者的时间和努力
        • 营造一个学生可以学习和成长的环境
        
        请记住：我们都在这里为学生创造更好的学习体验。
        让我们一起构建令人惊叹的东西！🎓
        """
    }
    
    // 版权声明内容
    private var copyrightNotice: String {
        """
        The Dreamer
        版权所有 © 2025 苏宇韬
        
        本项目由苏宇韬设计和开发。
        项目理念：由学生打造，为学生服务
        技术栈：SwiftUI + SwiftData + Swift Charts
        
        开发说明：
        本项目主要使用AI辅助开发。虽然我对代码库有基础的理解，
        但在实现过程中依赖AI工具。这种方式让我能够在技术专业知识
        有限的情况下，为学生群体创造有价值的工具。
        
        本软件包含源自Apple Inc.的示例代码组件。
        原始Apple代码 © 2024 Apple Inc.
        详细归属信息请见 ACKNOWLEDGEMENTS.md。
        
        如果本项目对您有帮助，请在您的衍生作品中保留此通知，
        并考虑为原始仓库点个Star：
        https://github.com/suyutao/TheDreamer
        
        如需技术讨论或合作机会，欢迎联系。
        """
    }
}

// 文档区块组件
struct DocumentSection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题栏
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // 内容区域
            if isExpanded {
                ScrollView {
                    Text(content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 300)
                .padding(.leading, 32)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 预览代码
#Preview {
    AboutView()
}