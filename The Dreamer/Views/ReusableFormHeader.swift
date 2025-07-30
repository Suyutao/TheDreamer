//
//  ReusableFormHeader.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI

/// [V23] 一个可复用的、用于表单顶部的标准化头部组件。
/// 它接受一个系统图标名称和一个标题作为输入。
struct ReusableFormHeader: View {
    let iconName: String
    let title: String
    let iconColor: Color // [V23] 增加颜色参数，使其更灵活

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .padding()
                .background(Circle().fill(iconColor.gradient))
            
            Text(title)
                .font(.title2).bold()
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .padding(.vertical)
    }
}

#Preview {
    Form {
        ReusableFormHeader(
            iconName: "plus.circle.fill",
            title: "这是一个预览",
            iconColor: .blue
        )
    }
}
