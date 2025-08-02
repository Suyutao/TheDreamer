//
//  CommonComponents.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

// 功能简介：
// 这个文件包含了应用中常用的可复用UI组件。
// 表单头部 (FormHeader)：用于在表单或设置页面顶部显示一个带图标的标题

// 常用名词解释：
// - View: SwiftUI中的基本界面构建单元
// - struct: 一种数据结构，用于封装相关的属性和功能
// - body: View的必需属性，定义了界面的具体内容
// - Image: 用于显示图片或系统图标
// - Text: 用于显示文本
// - Color: 用于定义颜色
// - VStack: 垂直堆叠布局容器

import SwiftUI

// MARK: - Form Header
// 表单头部组件：显示一个带图标的标题，通常用于表单或设置页面的顶部
struct FormHeader: View {
    // 图标名称：指定要显示的系统图标名称
    let iconName: String
    // 标题文本：显示在图标下方的标题文字
    let title: String
    // 图标颜色：指定图标的背景颜色
    let iconColor: Color

    // 界面构建部分：定义了组件的具体外观
    var body: some View {
        // 垂直堆叠布局，元素之间间距为8点
        VStack(spacing: 8) {
            // 显示系统图标
            Image(systemName: iconName)
                // 设置图标大小为40点
                .font(.system(size: 40))
                // 设置图标颜色为白色
                .foregroundStyle(iconColor.gradient)
                // 为图标添加内边距
                .padding()
                // 为图标添加圆形背景，背景色为指定的颜色渐变
                .background(Circle().fill(.background.tertiary))
            
            // 显示标题文本
            Text(title)
                // 设置字体为标题2号并加粗
                .font(.title).bold()
        }
        // 设置组件宽度占满可用空间
        .frame(maxWidth: .infinity)
        // 设置列表行背景为透明
        .listRowBackground(Color.clear)
    }
}

#Preview("Header") {
    Form {
        FormHeader(
            iconName: "plus.circle.fill",
            title: "这是一个预览",
            iconColor: .blue
        )
    }
}