//
//  ScatterChartView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// 功能简介：
// 散点密度图组件 - 分析分数绝对值与得分率的关系
// X轴：分数绝对值，Y轴：得分率，颜色：科目/题型
// 可以直观地看见一次考试或多次考试的分数分布位置
// 左下角：得分率小且分数少，左上角：得分率高但分数少
// 右上角：全能王（高分高得分率），右下角：分数高但得分率低

import SwiftUI
import Charts
import SwiftData

// MARK: - 数据模型

/// 散点图数据点
struct ScatterDataPoint: Identifiable {
    let id = UUID()
    let absoluteScore: Double    // X轴：分数绝对值
    let scoreRate: Double        // Y轴：得分率
    let category: String         // 分类（科目/题型）
    let color: Color            // 显示颜色
    let questionNumber: String?  // 题号
    let examName: String?       // 考试名称
    let date: Date?             // 考试日期
    let totalScore: Double      // 总分
    let description: String?    // 描述信息
}

/// 散点图分类类型
enum ScatterCategoryType {
    case subject        // 按科目分类
    case questionType   // 按题型分类
    case exam          // 按考试分类
    case custom        // 自定义分类
}

/// 趋势线类型
enum TrendLineType {
    case none          // 无趋势线
    case linear        // 线性趋势线
    case polynomial    // 多项式趋势线
    case average       // 平均线
}

// MARK: - 散点图组件

struct ScatterChartView: View {
    // MARK: - 参数
    let dataPoints: [ScatterDataPoint]
    let categoryType: ScatterCategoryType
    let trendLineType: TrendLineType
    let title: String
    let showDensityRegions: Bool
    
    // MARK: - 状态
    @State private var selectedPoint: ScatterDataPoint?
    @State private var hoveredPoint: ScatterDataPoint?
    
    // MARK: - 初始化
    init(
        dataPoints: [ScatterDataPoint],
        categoryType: ScatterCategoryType = .subject,
        trendLineType: TrendLineType = .linear,
        title: String = "散点密度图",
        showDensityRegions: Bool = true
    ) {
        self.dataPoints = dataPoints
        self.categoryType = categoryType
        self.trendLineType = trendLineType
        self.title = title
        self.showDensityRegions = showDensityRegions
    }
    
    // MARK: - 计算属性
    
    /// X轴最大值
    private var xAxisMaxValue: Double {
        let maxScore = dataPoints.map { $0.absoluteScore }.max() ?? 100
        return ceil(maxScore / 10) * 10 // 向上取整到10的倍数
    }
    
    /// 分类颜色映射
    private var categoryColors: [String: Color] {
        let categories = Array(Set(dataPoints.map { $0.category }))
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan, .mint, .indigo]
        
        var colorMap: [String: Color] = [:]
        for (index, category) in categories.enumerated() {
            colorMap[category] = colors[index % colors.count]
        }
        return colorMap
    }
    
    /// 趋势线数据点
    private var trendLinePoints: [CGPoint] {
        guard trendLineType != .none && !dataPoints.isEmpty else { return [] }
        
        switch trendLineType {
        case .linear:
            return calculateLinearTrendLine()
        case .polynomial:
            return calculatePolynomialTrendLine()
        case .average:
            return calculateAverageLines()
        case .none:
            return []
        }
    }
    
    // MARK: - 视图主体
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            chartHeader
            
            HStack(spacing: 20) {
                mainChart
                sidePanel
            }
        }
        .padding()
    }
    
    /// 主图表
    private var mainChart: some View {
        Chart {
            if showDensityRegions {
                densityRegions
            }
            
            ForEach(dataPoints) { point in
                PointMark(
                    x: .value("分数", point.absoluteScore),
                    y: .value("得分率", point.scoreRate)
                )
                .foregroundStyle(categoryColors[point.category] ?? .blue)
                .symbolSize(selectedPoint?.id == point.id ? 120 : (hoveredPoint?.id == point.id ? 80 : 50))
                .opacity(selectedPoint == nil ? 1.0 : (selectedPoint?.id == point.id ? 1.0 : 0.6))
            }
            
            if !trendLinePoints.isEmpty {
                trendLineMarks
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
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(Int(doubleValue))%")
                    }
                }
            }
        }
        .chartXScale(domain: 0...xAxisMaxValue)
        .chartYScale(domain: 0...100)
        .chartBackground { chartProxy in
            chartInteractionBackground(chartProxy: chartProxy)
        }
        .frame(height: 400)
    }
    
    /// 趋势线标记
    @ChartContentBuilder
    private var trendLineMarks: some ChartContent {
        ForEach(Array(trendLinePoints.enumerated()), id: \.offset) { index, point in
            if index < trendLinePoints.count - 1 {
                LineMark(
                    x: .value("分数", Double(point.x)),
                    y: .value("得分率", Double(point.y))
                )
                .foregroundStyle(.gray)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
        }
    }
    
    /// 图表交互背景
    private func chartInteractionBackground(chartProxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleChartTap(at: location, geometry: geometry, chartProxy: chartProxy)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleChartHover(at: value.location, geometry: geometry, chartProxy: chartProxy)
                        }
                        .onEnded { _ in
                            hoveredPoint = nil
                        }
                )
        }
    }
    
    /// 侧边面板
    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            legendView
            
            if let selected = selectedPoint {
                selectedPointDetails(selected)
            } else {
                analysisInsights
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 子视图
    
    /// 图表标题
    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("分析分数绝对值与得分率的关系分布")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    /// 密度区域背景
    @ChartContentBuilder
    private var densityRegions: some ChartContent {
        // 左下角：低分低得分率区域
        RectangleMark(
            xStart: .value("X Start", 0),
            xEnd: .value("X End", xAxisMaxValue * 0.3),
            yStart: .value("Y Start", 0),
            yEnd: .value("Y End", 30)
        )
        .foregroundStyle(.red.opacity(0.1))
        
        // 左上角：低分高得分率区域
        RectangleMark(
            xStart: .value("X Start", 0),
            xEnd: .value("X End", xAxisMaxValue * 0.3),
            yStart: .value("Y Start", 70),
            yEnd: .value("Y End", 100)
        )
        .foregroundStyle(.orange.opacity(0.1))
        
        // 右上角：高分高得分率区域（全能王）
        RectangleMark(
            xStart: .value("X Start", xAxisMaxValue * 0.7),
            xEnd: .value("X End", xAxisMaxValue),
            yStart: .value("Y Start", 70),
            yEnd: .value("Y End", 100)
        )
        .foregroundStyle(.green.opacity(0.1))
        
        // 右下角：高分低得分率区域
        RectangleMark(
            xStart: .value("X Start", xAxisMaxValue * 0.7),
            xEnd: .value("X End", xAxisMaxValue),
            yStart: .value("Y Start", 0),
            yEnd: .value("Y End", 30)
        )
        .foregroundStyle(.yellow.opacity(0.1))
    }
    
    /// 图例
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("图例")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // 分类图例
            ForEach(Array(categoryColors.keys.sorted()), id: \.self) { category in
                HStack(spacing: 6) {
                    Circle()
                        .fill(categoryColors[category] ?? .blue)
                        .frame(width: 10, height: 10)
                    
                    Text(category)
                        .font(.caption)
                }
            }
            
            Divider()
            
            // 区域说明
            if showDensityRegions {
                VStack(alignment: .leading, spacing: 4) {
                    Text("区域说明")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    regionLegendItem(color: .green, title: "全能王", description: "高分高得分率")
                    regionLegendItem(color: .orange, title: "效率型", description: "低分高得分率")
                    regionLegendItem(color: .yellow, title: "潜力型", description: "高分低得分率")
                    regionLegendItem(color: .red, title: "待提升", description: "低分低得分率")
                }
            }
        }
    }
    
    /// 区域图例项
    private func regionLegendItem(color: Color, title: String, description: String) -> some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color.opacity(0.3))
                .frame(width: 10, height: 10)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// 选中点的详细信息
    private func selectedPointDetails(_ point: ScatterDataPoint) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("详细信息")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 3) {
                if let questionNumber = point.questionNumber {
                    Text("题号: \(questionNumber)")
                }
                Text("分类: \(point.category)")
                Text("分数: \(Int(point.absoluteScore))/\(Int(point.totalScore))")
                Text("得分率: \(point.scoreRate, specifier: "%.1f")%")
                
                if let examName = point.examName {
                    Text("考试: \(examName)")
                }
                
                if let date = point.date {
                    Text("日期: \(date, format: .dateTime.month().day())")
                }
                
                if let description = point.description {
                    Text("说明: \(description)")
                }
            }
            .font(.caption2)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
    
    /// 分析洞察
    private var analysisInsights: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("分析洞察")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                insightItem("数据点总数", "\(dataPoints.count)")
                insightItem("平均得分率", String(format: "%.1f", averageScoreRate) + "%")
                insightItem("平均分数", String(format: "%.1f", averageAbsoluteScore))
                
                if let bestCategory = bestPerformingCategory {
                    insightItem("最佳表现", bestCategory)
                }
                
                if let improvementArea = improvementArea {
                    insightItem("改进方向", improvementArea)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
    
    /// 洞察项
    private func insightItem(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title + ":")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - 计算属性（分析）
    
    /// 平均得分率
    private var averageScoreRate: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.reduce(0) { $0 + $1.scoreRate } / Double(dataPoints.count)
    }
    
    /// 平均分数
    private var averageAbsoluteScore: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.reduce(0) { $0 + $1.absoluteScore } / Double(dataPoints.count)
    }
    
    /// 最佳表现分类
    private var bestPerformingCategory: String? {
        let categoryPerformance = Dictionary(grouping: dataPoints) { $0.category }
            .mapValues { points in
                points.reduce(0) { $0 + $1.scoreRate } / Double(points.count)
            }
        
        return categoryPerformance.max { $0.value < $1.value }?.key
    }
    
    /// 改进方向
    private var improvementArea: String? {
        let lowPerformancePoints = dataPoints.filter { $0.scoreRate < 60 }
        guard !lowPerformancePoints.isEmpty else { return nil }
        
        let categoryCount = Dictionary(grouping: lowPerformancePoints) { $0.category }
            .mapValues { $0.count }
        
        return categoryCount.max { $0.value < $1.value }?.key
    }
    
    // MARK: - 趋势线计算
    
    /// 计算线性趋势线
    private func calculateLinearTrendLine() -> [CGPoint] {
        guard dataPoints.count >= 2 else { return [] }
        
        let n = Double(dataPoints.count)
        let sumX = dataPoints.reduce(0) { $0 + $1.absoluteScore }
        let sumY = dataPoints.reduce(0) { $0 + $1.scoreRate }
        let sumXY = dataPoints.reduce(0) { $0 + ($1.absoluteScore * $1.scoreRate) }
        let sumX2 = dataPoints.reduce(0) { $0 + ($1.absoluteScore * $1.absoluteScore) }
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        let startX: Double = 0
        let endX = xAxisMaxValue
        let startY = slope * startX + intercept
        let endY = slope * endX + intercept
        
        return [
            CGPoint(x: startX, y: max(0, min(100, startY))),
            CGPoint(x: endX, y: max(0, min(100, endY)))
        ]
    }
    
    /// 计算多项式趋势线（简化版二次函数）
    private func calculatePolynomialTrendLine() -> [CGPoint] {
        // 简化实现，返回平滑曲线的近似点
        guard dataPoints.count >= 3 else { return calculateLinearTrendLine() }
        
        let sortedPoints = dataPoints.sorted { $0.absoluteScore < $1.absoluteScore }
        var trendPoints: [CGPoint] = []
        
        let step = xAxisMaxValue / 20
        for i in 0...20 {
            let x = Double(i) * step
            // 使用移动平均来近似多项式趋势
            let nearbyPoints = sortedPoints.filter { abs($0.absoluteScore - x) <= step * 2 }
            if !nearbyPoints.isEmpty {
                let avgY = nearbyPoints.reduce(0) { $0 + $1.scoreRate } / Double(nearbyPoints.count)
                trendPoints.append(CGPoint(x: x, y: avgY))
            }
        }
        
        return trendPoints
    }
    
    /// 计算平均线
    private func calculateAverageLines() -> [CGPoint] {
        let avgX = averageAbsoluteScore
        let avgY = averageScoreRate
        
        return [
            // 垂直平均线
            CGPoint(x: avgX, y: 0),
            CGPoint(x: avgX, y: 100),
            // 水平平均线
            CGPoint(x: 0, y: avgY),
            CGPoint(x: xAxisMaxValue, y: avgY)
        ]
    }
    
    // MARK: - 交互处理
    
    /// 处理图表点击
    private func handleChartTap(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        if let x = chartProxy.value(atX: location.x, as: Double.self),
           let y = chartProxy.value(atY: location.y, as: Double.self) {
            
            // 找到最接近的数据点
            let closestPoint = dataPoints.min { point1, point2 in
                let distance1 = sqrt(pow(point1.absoluteScore - x, 2) + pow(point1.scoreRate - y, 2))
                let distance2 = sqrt(pow(point2.absoluteScore - x, 2) + pow(point2.scoreRate - y, 2))
                return distance1 < distance2
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPoint = selectedPoint?.id == closestPoint?.id ? nil : closestPoint
            }
        }
    }
    
    /// 处理图表悬停
    private func handleChartHover(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        if let x = chartProxy.value(atX: location.x, as: Double.self),
           let y = chartProxy.value(atY: location.y, as: Double.self) {
            
            // 找到最接近的数据点（在一定范围内）
            let threshold: Double = 10 // 悬停检测阈值
            let nearbyPoint = dataPoints.first { point in
                let distance = sqrt(pow(point.absoluteScore - x, 2) + pow(point.scoreRate - y, 2))
                return distance <= threshold
            }
            
            hoveredPoint = nearbyPoint
        }
    }
}

// MARK: - 便利构造器

extension ScatterChartView {
    /// 创建基于考试的散点图
    static func examScatterChart(
        exams: [Exam],
        categoryType: ScatterCategoryType = .subject
    ) -> ScatterChartView {
        var dataPoints: [ScatterDataPoint] = []
        
        for exam in exams {
            for question in exam.questions {
                let category: String
                switch categoryType {
                case .subject:
                    category = exam.subject?.name ?? "未知科目"
                case .questionType:
                    category = question.type?.name ?? "未知题型"
                case .exam:
                    category = exam.name
                case .custom:
                    category = "自定义"
                }
                
                let dataPoint = ScatterDataPoint(
                    absoluteScore: question.score,
                    scoreRate: question.points > 0 ? (question.score / question.points) * 100 : 0,
                    category: category,
                    color: .blue, // 将在视图中重新分配
                    questionNumber: question.questionNumber,
                    examName: exam.name,
                    date: exam.date,
                    totalScore: question.points,
                    description: nil
                )
                
                dataPoints.append(dataPoint)
            }
        }
        
        return ScatterChartView(
            dataPoints: dataPoints,
            categoryType: categoryType,
            title: "题目得分分析"
        )
    }
}

// MARK: - 预览

#Preview {
    let sampleData = [
        ScatterDataPoint(
            absoluteScore: 15,
            scoreRate: 75,
            category: "数学",
            color: .blue,
            questionNumber: "1",
            examName: "期中考试",
            date: Date(),
            totalScore: 20,
            description: "选择题"
        ),
        ScatterDataPoint(
            absoluteScore: 8,
            scoreRate: 40,
            category: "数学",
            color: .blue,
            questionNumber: "2",
            examName: "期中考试",
            date: Date(),
            totalScore: 20,
            description: "填空题"
        ),
        ScatterDataPoint(
            absoluteScore: 25,
            scoreRate: 83,
            category: "语文",
            color: .green,
            questionNumber: "1",
            examName: "期中考试",
            date: Date(),
            totalScore: 30,
            description: "阅读理解"
        )
    ]
    
    return ScatterChartView(
        dataPoints: sampleData,
        categoryType: .subject,
        title: "题目得分分析"
    )
    .padding()
}