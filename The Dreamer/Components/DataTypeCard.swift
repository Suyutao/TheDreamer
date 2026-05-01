//
//  DataTypeCard.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI

/// 数据类型选择卡片组件
struct DataTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .tint(color)
    }
}

/// 信息卡片组件
struct InfoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GroupBox {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DataTypeCard(
            title: "考试",
            subtitle: "正式考试记录",
            icon: "doc.text.fill",
            isSelected: true,
            color: .blue
        ) {
            print("考试 selected")
        }

        DataTypeCard(
            title: "练习",
            subtitle: "日常练习记录",
            icon: "pencil.and.ruler.fill",
            isSelected: false,
            color: .green
        ) {
            print("练习 selected")
        }

        InfoCard {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("成绩")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextField("请输入成绩", text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 8)
                }

                Spacer()
            }
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
