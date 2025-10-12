//
//  TimeRangeSelector.swift
//  The Dreamer
//
//  Created by AI Assistant
//

import SwiftUI

/// 时间范围选择器组件
/// 提供月、6个月、年的分段选择控制器
struct TimeRangeSelector: View {
    
    // MARK: - 时间范围选项
    enum TimeRange: String, CaseIterable {
        case month = "月"
        case sixMonths = "6个月"
        case year = "年"
        
        /// 获取对应的日期范围
        var dateRange: ClosedRange<Date>? {
            let now = Date()
            let calendar = Calendar.current
            
            switch self {
            case .month:
                guard let startDate = calendar.date(byAdding: .month, value: -1, to: now) else { return nil }
                return startDate...now
            case .sixMonths:
                guard let startDate = calendar.date(byAdding: .month, value: -6, to: now) else { return nil }
                return startDate...now
            case .year:
                guard let startDate = calendar.date(byAdding: .year, value: -1, to: now) else { return nil }
                return startDate...now
            }
        }
    }
    
    // MARK: - 属性
    @Binding var selectedRange: TimeRange
    
    // MARK: - 视图主体
    var body: some View {
        Picker("时间范围", selection: $selectedRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue)
                    .tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedRange = TimeRangeSelector.TimeRange.month
    
    return VStack {
        TimeRangeSelector(selectedRange: $selectedRange)
        
        Text("选中的范围: \(selectedRange.rawValue)")
            .padding()
    }
    .padding()
}