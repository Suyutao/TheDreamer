//
//  AnalysisView.swift
//  The Dreamer
//
//  Created by 苏宇韬 on 7/30/25.
//

import SwiftUI

struct AnalysisView: View {
    @State private var showingAddDataSheet = false
    @State private var addableDataType: AddableDataType = .exam // 默认添加考试
    
    var body: some View {
        NavigationView {
            // 这里将是我们的数据列表
            Text("详细数据列表区域")
                .navigationTitle("所有数据")
                .toolbar {
                    // 左上角的视图管理菜单
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            // 这里将放置我们V20讨论过的视图切换选项
                            Button("按科目分组", action: {})
                            Button("按时间排序", action: {})
                            
                            Divider()
                            
                            Button("管理科目与模板...", action: {})
                            
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    
                    // 右上角的添加数据菜单
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button("添加考试", action: {
                                addableDataType = .exam
                                showingAddDataSheet = true
                            })
                            
                            Button("添加练习", action: {
                                addableDataType = .practice
                                showingAddDataSheet = true
                            })
                        } label: {
                            Text("添加数据")
                        }
                    }
                }
                .sheet(isPresented: $showingAddDataSheet) {
                    // 弹出我们已经完成的添加数据视图
                    AddDataView(dataType: addableDataType)
                }
        }
    }
}

#Preview {
    AnalysisView()
}
