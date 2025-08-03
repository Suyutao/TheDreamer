//
//  CommonComponents.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件包含了应用中常用的可复用UI组件。
// 它定义了两种常见的界面元素：
// 1. 表单头部 (FormHeader)：用于在表单或设置页面顶部显示一个带图标的标题
// 2. 空状态视图 (EmptyStateView)：当没有数据可显示时，用于提示用户当前为空的状态

// 常用名词解释：
// - View: SwiftUI中的基本界面构建单元
// - struct: 一种数据结构，用于封装相关的属性和功能
// - body: View的必需属性，定义了界面的具体内容
// - Image: 用于显示图片或系统图标
// - Text: 用于显示文本
// - Color: 用于定义颜色
// - VStack: 垂直堆叠布局容器

import SwiftUI

// MARK: - Empty State View
// 空状态视图组件：当没有数据可显示时，向用户展示提示信息
struct EmptyStateView: View {
    // [V26] 新增 iconName 参数，并提供默认值
    // 图标名称：指定要显示的系统图标名称
    let iconName: String
    // 标题文本：显示在图标下方的主要提示文字
    let title: String
    // 消息文本：显示在标题下方的详细说明文字
    let message: String
    
    // 界面构建部分：定义了组件的具体外观
    var body: some View {
        // 垂直堆叠布局，元素之间间距为16点
        VStack(spacing: 16) {
            // 显示系统图标
            Image(systemName: iconName) // [V26] 使用传入的图标
                // 设置图标大小为70点
                .font(.system(size: 70))
                // 设置图标颜色为次要颜色（通常是灰色）
                .foregroundStyle(.secondary)
            
            // 显示标题文本
            Text(title)
                // 设置字体为标题号并加粗
                .font(.title).bold()
                // 设置文本颜色为主要颜色（通常是黑色）
                .foregroundStyle(.primary)
            
            // 显示消息文本
            Text(message)
                // 设置字体为副标题
                .font(.subheadline)
                // 设置文本颜色为次要颜色（通常是灰色）
                .foregroundStyle(.secondary)
                // 设置文本居中对齐并允许多行显示
                .multilineTextAlignment(.center)
                // 在水平方向上添加内边距
                .padding(.horizontal)
        }
        // 为整个组件添加内边距
        .padding()
    }
}

#Preview("EmptyStateView") {
    EmptyStateView(
        iconName:  "plus.circle.fill",
        title: "没有数据",
        message: "目前没有任何数据，请添加新的项目。"
    )
}
