//
//  NativeGestures.swift
//  The Dreamer
//
//  Created by AI Assistant on 2025-01-13.
//

import SwiftUI
import UIKit
import Combine

// MARK: - Three Finger Tap Gesture

/// 三指点击手势，用于触发编辑菜单
struct ThreeFingerTapGesture: UIViewRepresentable {
    let action: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture))
        gesture.numberOfTouchesRequired = 3 // 三指点击
        gesture.delegate = context.coordinator
        view.addGestureRecognizer(gesture)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func handleGesture() {
            action()
        }
        
        func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
            true // 允许与其他手势同时识别
        }
    }
}

// MARK: - Two Finger Multi-Select Gesture

/// 双指多选手势，用于快速选择多个项目
struct TwoFingerMultiSelectGesture: UIViewRepresentable {
    let onSelectionStart: () -> Void
    let onSelectionChanged: (CGPoint) -> Void
    let onSelectionEnd: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan))
        gesture.minimumNumberOfTouches = 2
        gesture.maximumNumberOfTouches = 2
        gesture.delegate = context.coordinator
        view.addGestureRecognizer(gesture)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onSelectionStart: onSelectionStart,
            onSelectionChanged: onSelectionChanged,
            onSelectionEnd: onSelectionEnd
        )
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let onSelectionStart: () -> Void
        let onSelectionChanged: (CGPoint) -> Void
        let onSelectionEnd: () -> Void
        
        init(onSelectionStart: @escaping () -> Void,
             onSelectionChanged: @escaping (CGPoint) -> Void,
             onSelectionEnd: @escaping () -> Void) {
            self.onSelectionStart = onSelectionStart
            self.onSelectionChanged = onSelectionChanged
            self.onSelectionEnd = onSelectionEnd
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            
            switch gesture.state {
            case .began:
                onSelectionStart()
            case .changed:
                onSelectionChanged(location)
            case .ended, .cancelled:
                onSelectionEnd()
            default:
                break
            }
        }
        
        func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            // 避免与滚动手势冲突
            return !(other is UIPanGestureRecognizer)
        }
    }
}

// MARK: - View Extensions

extension View {
    /// 添加三指点击手势
    func threeFingerTap(perform action: @escaping () -> Void) -> some View {
        self.background(
            ThreeFingerTapGesture(action: action)
                .allowsHitTesting(true)
        )
    }
    
    /// 添加双指多选手势
    func twoFingerMultiSelect(
        onStart: @escaping () -> Void,
        onMove: @escaping (CGPoint) -> Void,
        onEnd: @escaping () -> Void
    ) -> some View {
        self.background(
            TwoFingerMultiSelectGesture(
                onSelectionStart: onStart,
                onSelectionChanged: onMove,
                onSelectionEnd: onEnd
            )
            .allowsHitTesting(true)
        )
    }
}

// MARK: - Gesture Feedback

/// 手势反馈管理器
class GestureFeedbackManager: ObservableObject {
    @Published var isMultiSelectActive = false
    @Published var showGestureHint = false
    
    /// 触发触觉反馈
    func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    /// 显示手势提示
    func showHint(for duration: TimeInterval = 2.0) {
        withAnimation(.easeInOut(duration: 0.3)) {
            showGestureHint = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showGestureHint = false
            }
        }
    }
}

// MARK: - Gesture Hint View

/// 手势提示视图
struct GestureHintView: View {
    let message: String = "已进入编辑模式"
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.white)
                Text(message)
                    .foregroundColor(.white)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.8))
            )
        }
        .padding(.top, 60)
    }
}