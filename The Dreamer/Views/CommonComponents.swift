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
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical.fill")
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
        .scaleEffect(0.85) // [V24] 缩小视图，使其更精致
        .offset(y: -50)
    }
}
