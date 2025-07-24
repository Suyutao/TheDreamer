//
//  AddDataView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/24/25.
//


import SwiftData
import SwiftUI

struct AddDataView: View {
    @Binding var showSheet: Bool
    var body: some View {
        VStack {
            Text("这里是添加成绩的表单")
            Button("关闭") {
                showSheet = false
            }
        }
        .padding()
    }
}

#Preview {
    AddDataView(showSheet: .constant(true))
}