//
//  UndoToastView.swift
//  The Dreamer
//
//  Created by AI Assistant on 2025-01-08.
//  Copyright © 2025 The Dreamer Team. All rights reserved.
//

import SwiftUI
import Combine

/// 撤销提示条组件
/// 用于在删除操作后显示短暂的撤销提示，提供用户友好的撤销机制
struct UndoToastView: View {
    /// 提示消息文本
    let message: String
    /// 撤销回调函数
    let onUndo: () -> Void
    /// 控制显示状态的绑定
    @Binding var isShowing: Bool
    
    /// 自动隐藏的延迟时间（秒）
    private let autoHideDelay: Double = 4.0
    
    var body: some View {
        if isShowing {
            HStack(spacing: 12) {
                // 撤销图标
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundColor(.white)
                    .font(.title3)
                
                // 提示消息
                Text(message)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // 撤销按钮
                Button("撤销") {
                    onUndo()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
                .foregroundColor(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.85))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 16)
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            ))
            .onAppear {
                // 自动隐藏计时器
                DispatchQueue.main.asyncAfter(deadline: .now() + autoHideDelay) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
            }
            .gesture(
                // 支持向下滑动手势关闭
                DragGesture()
                    .onEnded { value in
                        if value.translation.height > 50 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isShowing = false
                            }
                        }
                    }
            )
        }
    }
}

// MARK: - 撤销管理器

/// 撤销操作管理器
/// 用于管理删除操作的撤销状态和数据恢复
class CustomUndoManager: ObservableObject {
    /// 待撤销的操作数据
    @Published private var pendingUndoData: Any?
    /// 撤销操作的回调函数
    @Published private var undoAction: (() -> Void)?
    
    /// 注册一个可撤销的删除操作
    /// - Parameters:
    ///   - data: 被删除的数据对象
    ///   - action: 撤销时执行的恢复操作
    func registerUndo<T>(data: T, action: @escaping () -> Void) {
        pendingUndoData = data
        undoAction = action
    }
    
    /// 执行撤销操作
    func performUndo() {
        undoAction?()
        clearUndo()
    }
    
    /// 清除撤销数据
    func clearUndo() {
        pendingUndoData = nil
        undoAction = nil
    }
    
    /// 检查是否有待撤销的操作
    var hasUndoData: Bool {
        return undoAction != nil
    }
}

// MARK: - 预览

#Preview("撤销提示条") {
    VStack {
        Spacer()
        
        UndoToastView(
            message: "已删除考试记录",
            onUndo: {
                print("执行撤销操作")
            },
            isShowing: .constant(true)
        )
        .padding(.bottom, 50)
    }
    .background(Color.gray.opacity(0.1))
}