//
//  FormHeader.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI

// MARK: - Form Header
struct FormHeader: View {
    let iconName: String
    let title: String
    let iconColor: Color

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

// MARK: - Empty State View
struct EmptyStateView: View {
    // [V26] 新增 iconName 参数，并提供默认值
    let iconName: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName) // [V26] 使用传入的图标
                .font(.system(size: 70))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.title).bold()
                .foregroundStyle(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .offset(y: -50)
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

#Preview("EmptyStateView") {
    EmptyStateView(
        iconName:  "plus.circle.fill",
        title: "没有数据",
        message: "目前没有任何数据，请添加新的项目。"
    )
}
