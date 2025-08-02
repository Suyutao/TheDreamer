//
//  LineChartView.swift
//  The Dreamer
//
//  Created by AI Assistant
//

// MARK: - 功能简介与使用说明

/// # LineChartView (折线图组件)
///
/// **功能简介:**
/// 显示分数随时间变化的趋势，支持多条线（我的分数、班级总分、班级均分、目标分数）叠加，
/// 可通过参数调整科目、时间范围、显示的线条类型和预设风格。
///
/// **如何使用:**
/// 1.  **准备数据:** 创建 `[ChartDataPoint]` 数组，每个 `ChartDataPoint` 包含日期、分数、总分、考试名称、科目和线条类型。
///     ```swift
///     let myDataPoints: [ChartDataPoint] = [
///         .init(date: Date.from(year: 2023, month: 1, day: 1), score: 85, totalScore: 100, examName: "期中考", subject: "数学", type: .myScore),
///         .init(date: Date.from(year: 2023, month: 2, day: 1), score: 90, totalScore: 100, examName: "期末考", subject: "数学", type: .myScore),
///         .init(date: Date.from(year: 2023, month: 1, day: 1), score: 78, totalScore: 100, examName: "期中考", subject: "数学", type: .classAverage)
///     ]
///     ```
///
/// 2.  **创建视图实例:** 将准备好的数据传入 `LineChartView` 的初始化方法。
///     ```swift
///     LineChartView(
///         dataPoints: myDataPoints,
///         selectedSubject: "数学", // 可选：按科目过滤
///         dateRange: Date.from(year: 2023, month: 1, day: 1)...Date.from(year: 2023, month: 12, day: 31), // 可选：按时间范围过滤
///         visibleLines: [.myScore, .classAverage], // 可选：选择要显示的线条类型
///         chartStyle: .smooth, // 可选：选择图表风格 (.smooth 或 .linear)
///         showYAxisAsPercentage: true // 可选：Y轴是否显示为百分比
///     )
///     .frame(height: 300) // 设置图表高度
///     ```
///
/// 3.  **数据来源:** 通常，`ChartDataPoint` 数据会从您的 SwiftData 模型（如 `Exam` 或 `Practice`）中提取和转换而来。
///     例如，从 `Exam` 模型中获取我的分数数据点：
///     ```swift
///     @Query var exams: [Exam]
///     var myScoreDataPoints: [ChartDataPoint] {
///         exams.map { exam in
///             ChartDataPoint(
///                 date: exam.date,
///                 score: exam.score,
///                 totalScore: exam.totalScore,
///                 examName: exam.name,
///                 subject: exam.subject?.name ?? "未知科目",
///                 type: .myScore
///             )
///         }
///     }
///     // 然后在视图中使用：LineChartView(dataPoints: myScoreDataPoints)
///     ```

import SwiftUI
import Charts
import SwiftData

// MARK: - 数据模型

/// 图表数据点
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let totalScore: Double
    let examName: String
    let subject: String
    let type: LineType
    
    /// 得分率
    var scoreRate: Double {
        totalScore > 0 ? (score / totalScore) * 100 : 0
    }
}

/// 线条类型
enum LineType: String, CaseIterable {
    case myScore = "我的分数"
    case classTotal = "班级总分"
    case classAverage = "班级均分"
    case targetScore = "目标分数"
    
    var color: Color {
        switch self {
        case .myScore:
            return .blue
        case .classTotal:
            return .green
        case .classAverage:
            return .orange
        case .targetScore:
            return .red
        }
    }
    
    var isDashed: Bool {
        self == .targetScore
    }
}

/// 图表样式
enum ChartStyle {
    case smooth    // 平滑曲线
    case linear    // 直线连接
}

// MARK: - 折线图组件

struct LineChartView: View {
    // MARK: - 参数
    let dataPoints: [ChartDataPoint]
    let selectedSubject: String?
    let dateRange: ClosedRange<Date>?
    let visibleLines: Set<LineType>
    let chartStyle: ChartStyle
    let showYAxisAsPercentage: Bool
    
    // MARK: - 状态
    @State private var selectedDataPoint: ChartDataPoint?
    
    // MARK: - 初始化
    init(
        dataPoints: [ChartDataPoint],
        selectedSubject: String? = nil,
        dateRange: ClosedRange<Date>? = nil,
        visibleLines: Set<LineType> = [.myScore],
        chartStyle: ChartStyle = .smooth,
        showYAxisAsPercentage: Bool = false
    ) {
        self.dataPoints = dataPoints
        self.selectedSubject = selectedSubject
        self.dateRange = dateRange
        self.visibleLines = visibleLines
        self.chartStyle = chartStyle
        self.showYAxisAsPercentage = showYAxisAsPercentage
    }
    
    // MARK: - 计算属性
    
    /// 过滤后的数据点
    private var filteredDataPoints: [ChartDataPoint] {
        var filtered = dataPoints
        
        // 按科目过滤
        if let subject = selectedSubject {
            filtered = filtered.filter { $0.subject == subject }
        }
        
        // 按时间范围过滤
        if let range = dateRange {
            filtered = filtered.filter { range.contains($0.date) }
        }
        
        // 按可见线条过滤
        filtered = filtered.filter { visibleLines.contains($0.type) }
        
        return filtered.sorted { $0.date < $1.date }
    }
    
    /// Y轴显示值
    private func yAxisValue(for point: ChartDataPoint) -> Double {
        showYAxisAsPercentage ? point.scoreRate : point.score
    }
    
    /// Y轴最大值
    private var yAxisMaxValue: Double {
        if showYAxisAsPercentage {
            return 100
        } else {
            return filteredDataPoints.map { $0.score }.max() ?? 100
        }
    }
    
    // MARK: - 视图主体
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 图表标题和图例
            chartHeader
            
            // 主图表
            Chart(filteredDataPoints) { point in
                // 根据线条类型绘制不同样式
                if point.type.isDashed {
                    // 虚线（目标分数）
                    LineMark(
                        x: .value("时间", point.date),
                        y: .value("分数", yAxisValue(for: point))
                    )
                    .foregroundStyle(point.type.color)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .interpolationMethod(chartStyle == .smooth ? .catmullRom : .linear)
                } else {
                    // 实线
                    LineMark(
                        x: .value("时间", point.date),
                        y: .value("分数", yAxisValue(for: point))
                    )
                    .foregroundStyle(point.type.color)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(chartStyle == .smooth ? .catmullRom : .linear)
                }
                
                // 数据点
                PointMark(
                    x: .value("时间", point.date),
                    y: .value("分数", yAxisValue(for: point))
                )
                .foregroundStyle(point.type.color)
                .symbolSize(selectedDataPoint?.id == point.id ? 100 : 50)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    if showYAxisAsPercentage {
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
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            handleChartTap(at: location, geometry: geometry, chartProxy: chartProxy)
                        }
                }
            }
            .frame(height: 300)
            
            // 选中数据点的详细信息
            if let selectedPoint = selectedDataPoint {
                selectedPointDetails(selectedPoint)
            }
        }
        .padding()
    }
    
    // MARK: - 子视图
    
    /// 图表标题和图例
    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("分数趋势")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 图例
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(Array(visibleLines), id: \.self) { lineType in
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(lineType.color)
                            .frame(width: 16, height: 2)
                            .overlay {
                                if lineType.isDashed {
                                    Rectangle()
                                        .stroke(lineType.color, style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                                }
                            }
                        
                        Text(lineType.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    /// 选中数据点的详细信息
    private func selectedPointDetails(_ point: ChartDataPoint) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("详细信息")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("考试: \(point.examName)")
                    Text("科目: \(point.subject)")
                    Text("日期: \(point.date, format: .dateTime.year().month().day())")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(point.score))/\(Int(point.totalScore))")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("得分率: \(point.scoreRate, specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - 交互处理
    
    /// 处理图表点击
    private func handleChartTap(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        // 将点击位置转换为数据值
        if let date = chartProxy.value(atX: location.x, as: Date.self) {
            // 找到最接近的数据点
            let closestPoint = filteredDataPoints.min { point1, point2 in
                abs(point1.date.timeIntervalSince(date)) < abs(point2.date.timeIntervalSince(date))
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDataPoint = closestPoint
            }
        }
    }
}

// MARK: - 预览

#Preview {
    let sampleData = [
        ChartDataPoint(
            date: Date().addingTimeInterval(-86400 * 30),
            score: 85,
            totalScore: 100,
            examName: "期中考试",
            subject: "数学",
            type: .myScore
        ),
        ChartDataPoint(
            date: Date().addingTimeInterval(-86400 * 20),
            score: 92,
            totalScore: 100,
            examName: "月考",
            subject: "数学",
            type: .myScore
        ),
        ChartDataPoint(
            date: Date().addingTimeInterval(-86400 * 10),
            score: 88,
            totalScore: 100,
            examName: "期末考试",
            subject: "数学",
            type: .myScore
        )
    ]
    
    return LineChartView(
        dataPoints: sampleData,
        visibleLines: [.myScore],
        chartStyle: .smooth
    )
    .padding()
}