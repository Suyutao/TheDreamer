//
//  HeatmapView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// MARK: - 功能简介与使用说明

/// # HeatmapView (热力图组件)
///
/// **功能简介:**
/// 用于分析特定维度（如题型、考法、科目）在不同时间粒度下的能力变化趋势。
/// - **X轴:** 时间（按周、月、季度、年等粒度）
/// - **Y轴:** 分析维度（题型、考法、科目）
/// - **颜色深浅:** 表示该时间段内该维度的表现水平（如得分率、平均分、频次、进步幅度）。
///
/// **典型应用场景:**
/// - 识别哪些知识点在特定时间段表现较好或较差。
/// - 追踪长期学习进步或退步的趋势。
/// - 评估不同学习策略的效果。
///
/// **如何使用:**
/// 1. **准备数据:** 创建 `[HeatmapDataPoint]` 数组。
///    ```swift
///    // 示例数据：题型得分率热力图
///    let heatmapData: [HeatmapDataPoint] = [
///        .init(xValue: "2023-01", yValue: "选择题", intensity: 85, count: 10, averageScore: 8.5, totalScore: 10, date: Date(), details: ""),
///        .init(xValue: "2023-01", yValue: "填空题", intensity: 70, count: 8, averageScore: 7.0, totalScore: 10, date: Date(), details: ""),
///        .init(xValue: "2023-02", yValue: "选择题", intensity: 90, count: 12, averageScore: 9.0, totalScore: 10, date: Date(), details: "")
///    ]
///    ```
///
/// 2. **创建视图实例:**
///    ```swift
///    HeatmapView(
///        dataPoints: heatmapData,
///        heatmapType: .questionType,       // 按题型分析
///        timeGranularity: .month,         // 按月显示
///        intensityCalculation: .scoreRate,  // 颜色表示得分率
///        title: "题型能力变化",
///        showGrid: true,
///        showValues: false
///    )
///    .frame(height: 400)
///    ```
///
/// 3. **数据来源:** 通常从 SwiftData 模型(如 `Exam` 或 `Question`)中提取数据并转换为 `HeatmapDataPoint`。
///    组件会根据 `intensityCalculation` 自动计算颜色深浅。

import SwiftUI
import Charts
import SwiftData

// MARK: - 数据模型

/// 热力图数据点
struct HeatmapDataPoint: Identifiable {
    let id = UUID()
    let xValue: String          // X轴值（时间段）
    let yValue: String          // Y轴值（题型/考法/科目）
    let intensity: Double       // 强度值（0-100，表示得分率）
    let count: Int             // 该格子内的数据点数量
    let averageScore: Double   // 平均分数
    let totalScore: Double     // 总分
    let date: Date?            // 对应的日期
    let details: String?       // 详细信息
}

/// 热力图类型
enum HeatmapType {
    case questionType    // 题型热力图
    case cognitiveMethod // 考法热力图
    case subject        // 科目热力图
    case custom         // 自定义热力图
}

/// 时间粒度
enum TimeGranularity {
    case week           // 按周
    case month          // 按月
    case quarter        // 按季度
    case year           // 按年
    
    var displayName: String {
        switch self {
        case .week: return "周"
        case .month: return "月"
        case .quarter: return "季度"
        case .year: return "年"
        }
    }
}

/// 强度计算方式
enum IntensityCalculation {
    case scoreRate      // 得分率
    case averageScore   // 平均分
    case frequency      // 频次
    case improvement    // 进步幅度
}

// MARK: - 热力图组件

struct HeatmapView: View {
    // MARK: - 参数
    let dataPoints: [HeatmapDataPoint]
    let heatmapType: HeatmapType
    let timeGranularity: TimeGranularity
    let intensityCalculation: IntensityCalculation
    let title: String
    let showGrid: Bool
    let showValues: Bool
    
    // MARK: - 状态
    @State private var selectedCell: HeatmapDataPoint?
    @State private var hoveredCell: HeatmapDataPoint?
    @State private var showLegend: Bool = true
    
    // MARK: - 初始化
    init(
        dataPoints: [HeatmapDataPoint],
        heatmapType: HeatmapType = .questionType,
        timeGranularity: TimeGranularity = .month,
        intensityCalculation: IntensityCalculation = .scoreRate,
        title: String = "能力变化热力图",
        showGrid: Bool = true,
        showValues: Bool = false
    ) {
        self.dataPoints = dataPoints
        self.heatmapType = heatmapType
        self.timeGranularity = timeGranularity
        self.intensityCalculation = intensityCalculation
        self.title = title
        self.showGrid = showGrid
        self.showValues = showValues
    }
    
    // MARK: - 计算属性
    
    /// X轴标签（时间）
    private var xAxisLabels: [String] {
        Array(Set(dataPoints.map { $0.xValue })).sorted()
    }
    
    /// Y轴标签（类别）
    private var yAxisLabels: [String] {
        Array(Set(dataPoints.map { $0.yValue })).sorted()
    }
    
    /// 最大强度值
    private var maxIntensity: Double {
        dataPoints.map { $0.intensity }.max() ?? 100
    }
    
    /// 最小强度值
    private var minIntensity: Double {
        dataPoints.map { $0.intensity }.min() ?? 0
    }
    
    /// 强度颜色映射
    private func intensityColor(for intensity: Double) -> Color {
        let normalizedIntensity = (intensity - minIntensity) / (maxIntensity - minIntensity)
        
        switch intensityCalculation {
        case .scoreRate, .averageScore:
            // 绿色系：高分用深绿，低分用浅绿/白色
            return Color.green.opacity(0.2 + normalizedIntensity * 0.8)
        case .frequency:
            // 蓝色系：高频用深蓝，低频用浅蓝/白色
            return Color.blue.opacity(0.2 + normalizedIntensity * 0.8)
        case .improvement:
            // 渐变色：负值用红色，正值用绿色
            if intensity < 0 {
                return Color.red.opacity(0.2 + abs(normalizedIntensity) * 0.8)
            } else {
                return Color.green.opacity(0.2 + normalizedIntensity * 0.8)
            }
        }
    }
    
    // MARK: - 视图主体
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 图表标题和控制
            chartHeader
            
            HStack(spacing: 20) {
                // 主热力图
                VStack(alignment: .leading, spacing: 8) {
                    // Y轴标签和热力图网格
                    HStack(spacing: 0) {
                        // Y轴标签
                        VStack(alignment: .trailing, spacing: 0) {
                            ForEach(yAxisLabels.reversed(), id: \.self) { label in
                                Text(label)
                                    .font(.caption2)
                                    .frame(height: 30)
                                    .frame(maxWidth: 80, alignment: .trailing)
                            }
                        }
                        .padding(.trailing, 8)
                        
                        // 热力图网格
                        VStack(spacing: 1) {
                            ForEach(yAxisLabels.reversed(), id: \.self) { yLabel in
                                HStack(spacing: 1) {
                                    ForEach(xAxisLabels, id: \.self) { xLabel in
                                        heatmapCell(xValue: xLabel, yValue: yLabel)
                                    }
                                }
                            }
                        }
                        .background(showGrid ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(4)
                    }
                    
                    // X轴标签
                    HStack(spacing: 1) {
                        Spacer()
                            .frame(width: 88) // 对应Y轴标签宽度
                        
                        ForEach(xAxisLabels, id: \.self) { label in
                            Text(label)
                                .font(.caption2)
                                .frame(width: 40)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                // 侧边面板
                VStack(alignment: .leading, spacing: 12) {
                    if showLegend {
                        legendView
                    }
                    
                    if let selected = selectedCell {
                        selectedCellDetails(selected)
                    } else {
                        analysisInsights
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
    
    // MARK: - 子视图
    
    /// 图表标题和控制
    private var chartHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(heatmapType.displayName) × \(timeGranularity.displayName) 能力变化分析")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { showLegend.toggle() }) {
                    Image(systemName: showLegend ? "eye.fill" : "eye.slash")
                        .foregroundColor(.secondary)
                }
                
                Button(action: { selectedCell = nil }) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.secondary)
                }
                .disabled(selectedCell == nil)
            }
        }
    }
    
    /// 热力图单元格
    private func heatmapCell(xValue: String, yValue: String) -> some View {
        let dataPoint = dataPoints.first { $0.xValue == xValue && $0.yValue == yValue }
        let intensity = dataPoint?.intensity ?? 0
        let isSelected = selectedCell?.id == dataPoint?.id
        let isHovered = hoveredCell?.id == dataPoint?.id
        
        return Rectangle()
            .fill(dataPoint != nil ? intensityColor(for: intensity) : Color.gray.opacity(0.1))
            .frame(width: 40, height: 30)
            .overlay(
                Group {
                    if showValues, let dataPoint = dataPoint {
                        Text("\(Int(dataPoint.intensity))")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(intensity > 50 ? .white : .black)
                    }
                }
            )
            .overlay(
                Rectangle()
                    .stroke(isSelected ? Color.blue : (isHovered ? Color.gray : Color.clear), lineWidth: isSelected ? 2 : 1)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedCell = selectedCell?.id == dataPoint?.id ? nil : dataPoint
                }
            }
            .onHover { hovering in
                hoveredCell = hovering ? dataPoint : nil
            }
    }
    
    /// 图例
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("图例")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // 强度图例
            VStack(alignment: .leading, spacing: 4) {
                Text(intensityCalculation.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        let intensity = Double(index) / 4.0 * maxIntensity
                        Rectangle()
                            .fill(intensityColor(for: intensity))
                            .frame(width: 20, height: 12)
                    }
                }
                
                HStack {
                    Text("\(Int(minIntensity))")
                    Spacer()
                    Text("\(Int(maxIntensity))")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 100)
            }
            
            Divider()
            
            // 统计信息
            VStack(alignment: .leading, spacing: 2) {
                Text("统计")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                statisticItem("数据点", "\(dataPoints.count)")
                statisticItem("时间跨度", "\(xAxisLabels.count) \(timeGranularity.displayName)")
                statisticItem("类别数", "\(yAxisLabels.count)")
                statisticItem("平均强度", String(format: "%.1f", averageIntensity))
            }
        }
    }
    
    /// 统计项
    private func statisticItem(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title + ":")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
    
    /// 选中单元格详情
    private func selectedCellDetails(_ cell: HeatmapDataPoint) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("详细信息")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("时间: \(cell.xValue)")
                Text("类别: \(cell.yValue)")
                Text("\(intensityCalculation.displayName): \(cell.intensity, specifier: "%.1f")")
                Text("数据点: \(cell.count)")
                
                if cell.averageScore > 0 {
                    Text("平均分: \(cell.averageScore, specifier: "%.1f")/\(cell.totalScore, specifier: "%.0f")")
                }
                
                if let date = cell.date {
                    Text("日期: \(date, format: .dateTime.month().day())")
                }
                
                if let details = cell.details {
                    Text("说明: \(details)")
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
                if let bestPeriod = bestPerformingPeriod {
                    insightItem("最佳时期", bestPeriod)
                }
                
                if let bestCategory = bestPerformingCategory {
                    insightItem("最强项目", bestCategory)
                }
                
                if let improvementArea = improvementArea {
                    insightItem("改进方向", improvementArea)
                }
                
                if let trend = overallTrend {
                    insightItem("整体趋势", trend)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
    
    /// 洞察项
    private func insightItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - 计算属性（分析）
    
    /// 平均强度
    private var averageIntensity: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.reduce(0) { $0 + $1.intensity } / Double(dataPoints.count)
    }
    
    /// 最佳表现时期
    private var bestPerformingPeriod: String? {
        let periodPerformance = Dictionary(grouping: dataPoints) { $0.xValue }
            .mapValues { points in
                points.reduce(0) { $0 + $1.intensity } / Double(points.count)
            }
        
        return periodPerformance.max { $0.value < $1.value }?.key
    }
    
    /// 最佳表现类别
    private var bestPerformingCategory: String? {
        let categoryPerformance = Dictionary(grouping: dataPoints) { $0.yValue }
            .mapValues { points in
                points.reduce(0) { $0 + $1.intensity } / Double(points.count)
            }
        
        return categoryPerformance.max { $0.value < $1.value }?.key
    }
    
    /// 改进方向
    private var improvementArea: String? {
        let categoryPerformance = Dictionary(grouping: dataPoints) { $0.yValue }
            .mapValues { points in
                points.reduce(0) { $0 + $1.intensity } / Double(points.count)
            }
        
        return categoryPerformance.min { $0.value < $1.value }?.key
    }
    
    /// 整体趋势
    private var overallTrend: String? {
        guard xAxisLabels.count >= 2 else { return nil }
        
        let sortedPeriods = xAxisLabels.sorted()
        let firstPeriodAvg = dataPoints.filter { $0.xValue == sortedPeriods.first! }
            .reduce(0) { $0 + $1.intensity } / Double(max(1, dataPoints.filter { $0.xValue == sortedPeriods.first! }.count))
        let lastPeriodAvg = dataPoints.filter { $0.xValue == sortedPeriods.last! }
            .reduce(0) { $0 + $1.intensity } / Double(max(1, dataPoints.filter { $0.xValue == sortedPeriods.last! }.count))
        
        let change = lastPeriodAvg - firstPeriodAvg
        if abs(change) < 5 {
            return "保持稳定"
        } else if change > 0 {
            return "持续进步 (+" + String(format: "%.1f", change) + ")"
        } else {
            return "需要关注 (" + String(format: "%.1f", change) + ")"
        }
    }
}

// MARK: - 扩展

extension HeatmapType {
    var displayName: String {
        switch self {
        case .questionType: return "题型"
        case .cognitiveMethod: return "考法"
        case .subject: return "科目"
        case .custom: return "自定义"
        }
    }
}

extension IntensityCalculation {
    var displayName: String {
        switch self {
        case .scoreRate: return "得分率"
        case .averageScore: return "平均分"
        case .frequency: return "频次"
        case .improvement: return "进步幅度"
        }
    }
}

// MARK: - 便利构造器

extension HeatmapView {
    /// 创建基于考试的题型热力图
    static func questionTypeHeatmap(
        exams: [Exam],
        timeGranularity: TimeGranularity = .month
    ) -> HeatmapView {
        var dataPoints: [HeatmapDataPoint] = []
        
        // 按时间分组
        let examsByPeriod = Dictionary(grouping: exams) { exam in
            formatDateToPeriod(exam.date, granularity: timeGranularity)
        }
        
        // 为每个时间段和题型组合创建数据点
        for (period, periodExams) in examsByPeriod {
            let questionsByType = Dictionary(grouping: periodExams.flatMap { $0.questions }) { question in
                question.type?.name ?? "未知题型"
            }
            
            for (questionType, questions) in questionsByType {
                let totalScore = questions.reduce(0) { $0 + $1.score }
                let totalPossible = questions.reduce(0) { $0 + $1.points }
                let scoreRate = totalPossible > 0 ? (totalScore / totalPossible) * 100 : 0
                
                let dataPoint = HeatmapDataPoint(
                    xValue: period,
                    yValue: questionType,
                    intensity: scoreRate,
                    count: questions.count,
                    averageScore: totalScore / Double(questions.count),
                    totalScore: totalPossible / Double(questions.count),
                    date: periodExams.first?.date,
                    details: "\(questions.count)道题目"
                )
                
                dataPoints.append(dataPoint)
            }
        }
        
        return HeatmapView(
            dataPoints: dataPoints,
            heatmapType: .questionType,
            timeGranularity: timeGranularity,
            title: "题型能力变化热力图"
        )
    }
    
    /// 创建基于考试的科目热力图
    static func subjectHeatmap(
        exams: [Exam],
        timeGranularity: TimeGranularity = .month
    ) -> HeatmapView {
        var dataPoints: [HeatmapDataPoint] = []
        
        // 按时间分组
        let examsByPeriod = Dictionary(grouping: exams) { exam in
            formatDateToPeriod(exam.date, granularity: timeGranularity)
        }
        
        // 为每个时间段和科目组合创建数据点
        for (period, periodExams) in examsByPeriod {
            let examsBySubject = Dictionary(grouping: periodExams) { exam in
                exam.subject?.name ?? "未知科目"
            }
            
            for (subject, subjectExams) in examsBySubject {
                let totalScore = subjectExams.reduce(0) { $0 + $1.totalScore }
                let totalPossible = subjectExams.reduce(0) { $0 + $1.subject!.totalScore }
                let scoreRate = totalPossible > 0 ? (totalScore / totalPossible) * 100 : 0
                
                let dataPoint = HeatmapDataPoint(
                    xValue: period,
                    yValue: subject,
                    intensity: scoreRate,
                    count: subjectExams.count,
                    averageScore: totalScore / Double(subjectExams.count),
                    totalScore: totalPossible / Double(subjectExams.count),
                    date: subjectExams.first?.date,
                    details: "\(subjectExams.count)次考试"
                )
                
                dataPoints.append(dataPoint)
            }
        }
        
        return HeatmapView(
            dataPoints: dataPoints,
            heatmapType: .subject,
            timeGranularity: timeGranularity,
            title: "科目能力变化热力图"
        )
    }
}

// MARK: - 辅助函数

/// 将日期格式化为时间段
private func formatDateToPeriod(_ date: Date, granularity: TimeGranularity) -> String {
    let formatter = DateFormatter()
    
    switch granularity {
    case .week:
        formatter.dateFormat = "yyyy-'W'ww"
        return formatter.string(from: date)
    case .month:
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    case .quarter:
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        let quarter = (month - 1) / 3 + 1
        return "\(year)-Q\(quarter)"
    case .year:
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - 预览

#Preview {
    let sampleData = [
        HeatmapDataPoint(
            xValue: "2024-01",
            yValue: "选择题",
            intensity: 85,
            count: 10,
            averageScore: 17,
            totalScore: 20,
            date: Date(),
            details: "10道题目"
        ),
        HeatmapDataPoint(
            xValue: "2024-01",
            yValue: "填空题",
            intensity: 70,
            count: 5,
            averageScore: 14,
            totalScore: 20,
            date: Date(),
            details: "5道题目"
        ),
        HeatmapDataPoint(
            xValue: "2024-02",
            yValue: "选择题",
            intensity: 90,
            count: 8,
            averageScore: 18,
            totalScore: 20,
            date: Date(),
            details: "8道题目"
        ),
        HeatmapDataPoint(
            xValue: "2024-02",
            yValue: "填空题",
            intensity: 75,
            count: 6,
            averageScore: 15,
            totalScore: 20,
            date: Date(),
            details: "6道题目"
        )
    ]
    
    return HeatmapView(
        dataPoints: sampleData,
        heatmapType: .questionType,
        timeGranularity: .month,
        title: "题型能力变化热力图"
    )
    .padding()
}