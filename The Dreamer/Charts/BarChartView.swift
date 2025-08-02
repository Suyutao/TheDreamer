//
//  BarChartView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// 功能简介：
// 柱状图组件 - 包含单科分布和得分占比叠层柱状图
// 1. 单科分布：显示一次大考中各科目的分数/得分率
// 2. 得分占比叠层柱状图：显示每次大考中每门科目贡献的分数比例

import SwiftUI
import Charts
import SwiftData

// MARK: - 数据模型

/// 柱状图数据点
struct BarChartDataPoint: Identifiable {
    let id = UUID()
    let category: String  // 科目名称或时间标识
    let value: Double     // 分数值
    let totalValue: Double // 总分
    let subcategory: String? // 子分类（用于叠层图）
    let color: Color
    let examName: String?
    let date: Date?
    
    /// 得分率
    var percentage: Double {
        totalValue > 0 ? (value / totalValue) * 100 : 0
    }
}

/// 柱状图类型
enum BarChartType {
    case singleSubjectDistribution  // 单科分布
    case stackedScoreContribution   // 得分占比叠层图
}

/// 显示模式
enum BarDisplayMode {
    case absoluteScore  // 绝对分数
    case percentage     // 得分率
}

// MARK: - 柱状图组件

struct BarChartView: View {
    // MARK: - 参数
    let dataPoints: [BarChartDataPoint]
    let chartType: BarChartType
    let displayMode: BarDisplayMode
    let title: String
    
    // MARK: - 状态
    @State private var selectedBar: BarChartDataPoint?
    
    // MARK: - 初始化
    init(
        dataPoints: [BarChartDataPoint],
        chartType: BarChartType,
        displayMode: BarDisplayMode = .absoluteScore,
        title: String = "柱状图"
    ) {
        self.dataPoints = dataPoints
        self.chartType = chartType
        self.displayMode = displayMode
        self.title = title
    }
    
    // MARK: - 计算属性
    
    /// 显示值
    private func displayValue(for point: BarChartDataPoint) -> Double {
        switch displayMode {
        case .absoluteScore:
            return point.value
        case .percentage:
            return point.percentage
        }
    }
    
    /// Y轴最大值
    private var yAxisMaxValue: Double {
        switch displayMode {
        case .absoluteScore:
            if chartType == .stackedScoreContribution {
                // 叠层图需要计算每个类别的总和
                let groupedData = Dictionary(grouping: dataPoints) { $0.category }
                return groupedData.values.map { $0.reduce(0) { $0 + $1.value } }.max() ?? 100
            } else {
                return dataPoints.map { $0.value }.max() ?? 100
            }
        case .percentage:
            return 100
        }
    }
    
    // MARK: - 视图主体
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 图表标题
            chartHeader
            
            // 主图表
            Chart(dataPoints) { point in
                switch chartType {
                case .singleSubjectDistribution:
                    // 普通柱状图
                    BarMark(
                        x: .value("科目", point.category),
                        y: .value("分数", displayValue(for: point))
                    )
                    .foregroundStyle(point.color)
                    .cornerRadius(4)
                    
                case .stackedScoreContribution:
                    // 叠层柱状图
                    BarMark(
                        x: .value("时间", point.category),
                        y: .value("分数", displayValue(for: point)),
                        stacking: .standard
                    )
                    .foregroundStyle(point.color)
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    if displayMode == .percentage {
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))%")
                            }
                        }
                    } else {
                        AxisValueLabel()
                    }
                }
            }
            .chartYScale(domain: 0...yAxisMaxValue)
            .frame(height: 300)
            
            // 图例（仅叠层图显示）
            if chartType == .stackedScoreContribution {
                chartLegend
            }
            
            // 选中柱子的详细信息
            if let selectedBar = selectedBar {
                selectedBarDetails(selectedBar)
            }
        }
        .padding()
    }
    
    // MARK: - 子视图
    
    /// 图表标题
    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(chartType == .singleSubjectDistribution ? "各科目分数分布" : "各科目分数贡献")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    /// 图例
    private var chartLegend: some View {
        let uniqueSubcategories = Array(Set(dataPoints.compactMap { $0.subcategory }))
        let colors = Array(Set(dataPoints.map { $0.color }))
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(uniqueSubcategories.count, 3)), spacing: 8) {
            ForEach(Array(zip(uniqueSubcategories, colors)), id: \.0) { subcategory, color in
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                    
                    Text(subcategory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
    
    /// 选中柱子的详细信息
    private func selectedBarDetails(_ bar: BarChartDataPoint) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("详细信息")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("类别: \(bar.category)")
                    if let subcategory = bar.subcategory {
                        Text("科目: \(subcategory)")
                    }
                    if let examName = bar.examName {
                        Text("考试: \(examName)")
                    }
                    if let date = bar.date {
                        Text("日期: \(date, format: .dateTime.year().month().day())")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(bar.value))/\(Int(bar.totalValue))")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("得分率: \(bar.percentage, specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - 便利构造器

extension BarChartView {
    /// 创建单科分布图
    static func singleSubjectDistribution(
        exams: [Exam],
        displayMode: BarDisplayMode = .absoluteScore
    ) -> BarChartView {
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan]
        
        var dataPoints: [BarChartDataPoint] = []
        for (index, exam) in exams.enumerated() {
            let totalScore = exam.questions.reduce(0) { $0 + $1.score }
            let dataPoint = BarChartDataPoint(
                category: exam.subject?.name ?? "未知科目",
                value: totalScore,
                totalValue: exam.totalScore,
                subcategory: nil,
                color: colors[index % colors.count],
                examName: exam.name,
                date: exam.date
            )
            dataPoints.append(dataPoint)
        }
        
        return BarChartView(
            dataPoints: dataPoints,
            chartType: .singleSubjectDistribution,
            displayMode: displayMode,
            title: "科目分数分布"
        )
    }
    
    /// 创建得分占比叠层图
    static func stackedScoreContribution(
        examCollections: [ExamCollection],
        displayMode: BarDisplayMode = .absoluteScore
    ) -> BarChartView {
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan]
        var dataPoints: [BarChartDataPoint] = []
        
        for collection in examCollections {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            let categoryName = dateFormatter.string(from: collection.date)
            
            for (index, exam) in collection.exams.enumerated() {
                let totalScore = exam.questions.reduce(0) { $0 + $1.score }
                
                let dataPoint = BarChartDataPoint(
                    category: categoryName,
                    value: totalScore,
                    totalValue: exam.totalScore,
                    subcategory: exam.subject?.name ?? "未知科目",
                    color: colors[index % colors.count],
                    examName: exam.name,
                    date: exam.date
                )
                
                dataPoints.append(dataPoint)
            }
        }
        
        return BarChartView(
            dataPoints: dataPoints,
            chartType: .stackedScoreContribution,
            displayMode: displayMode,
            title: "得分占比分布"
        )
    }
}

// MARK: - 预览

#Preview {
    let sampleData = [
        BarChartDataPoint(
            category: "数学",
            value: 85,
            totalValue: 100,
            subcategory: nil,
            color: .blue,
            examName: "期中考试",
            date: Date()
        ),
        BarChartDataPoint(
            category: "语文",
            value: 92,
            totalValue: 100,
            subcategory: nil,
            color: .green,
            examName: "期中考试",
            date: Date()
        ),
        BarChartDataPoint(
            category: "英语",
            value: 88,
            totalValue: 100,
            subcategory: nil,
            color: .orange,
            examName: "期中考试",
            date: Date()
        )
    ]
    
    return BarChartView(
        dataPoints: sampleData,
        chartType: .singleSubjectDistribution,
        displayMode: .absoluteScore,
        title: "科目分数分布"
    )
    .padding()
}